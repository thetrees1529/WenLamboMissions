
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAttributes {

    struct StatisticView {
        string statistic;
        uint256 value;
    }

    function ownerOf(uint256 tokenId) external view returns (address);

    function getAttributes(uint256 _tokenId) external view returns (StatisticView[] memory);

}

interface INftRewarder is IERC165 {

    struct NftReward {
        IERC721 token;
        uint tokenId;
    }

    function rewardNftsTo(address account) external returns(NftReward[] memory);

}

interface IMissionsWallet {
    function withdrawAmount(address _to, uint256 _amount) external;
}

interface IMissions {

    event MissionEntered(address indexed owner, uint indexed tokenId, string mission);
    event MissionFinished(address indexed owner, uint indexed tokenId, string mission, History history);

    struct Prize {

        uint threshold;
        uint weighting;
        uint prize;

    }

    struct PrizeChart {

        string key;
        Prize[] prizes;

    }

    struct Requirement {

        string key;
        uint threshold;

    }

    struct NftRequirement {

        IERC721 nft;
        uint balance;

    }

    struct DependentMission {

        string mission;
        uint completions;

    }


    struct History {
        uint fixedPrize;
        uint extraPrize;
        INftRewarder.NftReward[] fixedNftRewards;
    }

    struct MissionConfig {
        
        DependentMission[] dependentMissions;
        Requirement[] requirements;
        NftRequirement[] nftRequirements;

        uint maxLifetime;
        uint cooldown;
        uint fixedPrize;
        INftRewarder fixedNftReward;
        PrizeChart prizeChart;
        uint length;

    }

    function enterMission(uint tokenId, string calldata mission) external;

    function endMission(uint tokenId) external;

    function getCooldownEnd(uint tokenId) external view returns(uint);

    function getCurrentMission(uint tokenId) external view returns(string memory);

    function getCurrentMissionEnd (uint tokenId) external view returns(uint);

    function getMissionHistoryLength(uint tokenId, string calldata mission) external view returns(uint);

    function getMissionHistory(uint tokenId, string calldata mission, uint firstIndex, uint lastIndex) external view returns(History[] memory history);

    function isInMission(uint tokenId) external view returns(bool);

    function setMissionConfig(string calldata mission, MissionConfig calldata missionConfig) external;

    function getMissionConfig(string calldata mission) external view returns(MissionConfig memory);

    function pause() external;

    function unpause() external;

}

contract Missions is IMissions, Ownable, ReentrancyGuard, Pausable {
    
    using SafeERC20 for IERC20;

    struct LamboData {
        
        bool inMission;
        string mission;
        uint end;
        uint cooldownEnd;
        mapping(string => History[]) history;

    }

    constructor(IAttributes lambos, IMissionsWallet missionsWallet) {
        _missionsWallet = missionsWallet;
        _lambos = lambos;
    }

    IMissionsWallet private _missionsWallet;
    IAttributes private _lambos;

    mapping(uint => LamboData) private _lambosToLamboData;
    mapping(string => MissionConfig) private _missionsToMissionConfigs;

    function enterMission(uint tokenId, string calldata mission) external override nonReentrant requireOwnerOf(tokenId) whenNotPaused {

        LamboData storage lamboData = _lambosToLamboData[tokenId];

        if(lamboData.inMission) {
            revert("Lambo is already in a mission.");
        } else {
            require(block.timestamp >= lamboData.cooldownEnd, "Lambo is under a cooldown for this mission.");
        }

        MissionConfig storage missionConfig = _missionsToMissionConfigs[mission];

        require(lamboData.history[mission].length < missionConfig.maxLifetime, "Lambo has entered this mission too many times.");

        Requirement[] storage requirements = missionConfig.requirements;
        for(uint i; i < requirements.length; i ++) {
            Requirement storage requirement = requirements[i];
            require(_valueOfStatistic(tokenId, requirement.key) >= requirement.threshold, "Lambo does not meet the requirements of this mission.");
        }

        NftRequirement[] storage nftRequirements = missionConfig.nftRequirements;
        for(uint i; i < nftRequirements.length; i ++) {
            NftRequirement storage nftRequirement = nftRequirements[i];
            require(nftRequirement.nft.balanceOf(msg.sender) > nftRequirement.balance, "You don't meet the nft requirements for this mission.");
        }

        DependentMission[] storage dependentMissions = missionConfig.dependentMissions;
        mapping(string => History[]) storage history = lamboData.history;
        for(uint i; i < dependentMissions.length; i ++) {
            DependentMission storage dependentMission = dependentMissions[i];
            require(history[dependentMission.mission].length >= dependentMission.completions, "Lambo does not meet the mission completions it depends on.");
        }

        lamboData.mission = mission;
        lamboData.inMission = true;
        lamboData.end = block.timestamp + missionConfig.length;

        emit MissionEntered(msg.sender, tokenId, mission);

    }

    function endMission(uint tokenId) external override nonReentrant requireOwnerOf(tokenId) whenNotPaused {

        LamboData storage lamboData = _lambosToLamboData[tokenId];

        require(lamboData.inMission, "Lambo is not in a mission.");
        require(block.timestamp >= lamboData.end, "Lambo is still in the mission.");

        MissionConfig storage missionConfig = _missionsToMissionConfigs[lamboData.mission];
        History[] storage history = lamboData.history[lamboData.mission];

        uint nonce = history.length;

        PrizeChart storage prizeChart = missionConfig.prizeChart;
        
        uint value = _valueOfStatistic(tokenId, prizeChart.key);

        Prize[] storage prizes = prizeChart.prizes;
        uint[] memory eligiblePrizes = new uint[](prizes.length);
        uint weightings;
        uint eligiblePrizeCount;

        for(uint i; i < prizes.length; i ++) {
            Prize storage prize = prizes[i];
            if(value >= prize.threshold) {
                weightings += prize.weighting;
                eligiblePrizes[eligiblePrizeCount] = i;
                eligiblePrizeCount ++;
            } 
        }

        history.push();

        History storage newHistory = history[history.length - 1];

        newHistory.fixedPrize = missionConfig.fixedPrize;

        for(uint i; i < eligiblePrizeCount; i ++) {
            Prize storage prize = prizes[eligiblePrizes[i]];
            uint randomInt = uint(sha256(abi.encode(nonce))) % weightings;
            if(randomInt < prize.weighting) {
                newHistory.extraPrize = prize.prize + missionConfig.fixedPrize;
                break;
            } else {
                nonce ++;
                weightings -= prize.weighting;
            }
        }

        lamboData.inMission = false;
        lamboData.cooldownEnd = block.timestamp + missionConfig.cooldown;

        (bool success,bytes memory data) = address(missionConfig.fixedNftReward).call(abi.encodeWithSelector(INftRewarder.rewardNftsTo.selector, msg.sender));
        if(success && data.length > 0) {
            INftRewarder.NftReward[] memory fixedNftRewards = abi.decode(data, (INftRewarder.NftReward[]));
            for(uint i; i < fixedNftRewards.length; i ++) {
                newHistory.fixedNftRewards.push(fixedNftRewards[i]);
            }
        }

        _missionsWallet.withdrawAmount(msg.sender, newHistory.fixedPrize + newHistory.extraPrize);

        emit MissionFinished(msg.sender, tokenId, lamboData.mission, newHistory);

    }

    function getCooldownEnd(uint tokenId) external override view returns(uint) {
        LamboData storage lamboData = _lambosToLamboData[tokenId];
        require(!lamboData.inMission, "Currently in mission.");
        return lamboData.cooldownEnd;
    }

    function getCurrentMission(uint tokenId) external override view returns(string memory) {
        LamboData storage lamboData = _lambosToLamboData[tokenId];
        require(lamboData.inMission, "Lambo is not in a mission");
        return lamboData.mission;
    }

    function getCurrentMissionEnd(uint tokenId) external override view returns(uint) {
        LamboData storage lamboData = _lambosToLamboData[tokenId];
        require(lamboData.inMission, "Lambo is not in a mission");
        return lamboData.end;
    }

    function getMissionHistoryLength(uint tokenId, string calldata mission) external override view returns(uint) {
        return _lambosToLamboData[tokenId].history[mission].length;
    }

    function getMissionHistory(uint tokenId, string calldata mission, uint firstIndex, uint lastIndex) external override view returns(History[] memory history) {
        history = new History[](lastIndex - firstIndex + 1);
        for(uint i; i < history.length; i ++) {
            history[i] = _lambosToLamboData[tokenId].history[mission][i + firstIndex];
        }
    }

    function isInMission(uint tokenId) external override view returns(bool) {
        return _lambosToLamboData[tokenId].inMission;
    }

    function setMissionConfig(string calldata mission, MissionConfig calldata missionConfig) external override nonReentrant onlyOwner {
        _missionsToMissionConfigs[mission] = missionConfig;
    }

    function getMissionConfig(string calldata mission) external override view returns(MissionConfig memory) {
        return _missionsToMissionConfigs[mission];
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function _valueOfStatistic(uint tokenId, string memory key) private view returns(uint value) {
        bytes32 keyHash = sha256(bytes(key));
        IAttributes.StatisticView[] memory statistics = _lambos.getAttributes(tokenId);
        for(uint i; i < statistics.length; i ++) {
            IAttributes.StatisticView memory statistic = statistics[i];
            if(sha256(bytes(statistic.statistic)) == keyHash) {
                return statistic.value;
            }
        }
    }

    modifier requireOwnerOf(uint tokenId) {
        require(msg.sender == _lambos.ownerOf(tokenId), "You don't own this lambo.");
        _;
    }

}