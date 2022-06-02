
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILambos is IERC721{

    struct StatisticView {
        string statistic;
        uint256 value;
    }

    function ownerOf(uint256 tokenId) external view returns (address);

    function getAttributes(uint256 _tokenId) external view returns (StatisticView[] memory);

}

interface IWallet {
    function withdrawAmount(address _to, uint256 _amount) external;
    function hVilleAddress() external view returns(address);
}

interface IMissions {
    struct Level {
        string stat;
        uint value;
    }
    struct MinLevel {
        Level minLevel;
    }
    struct Completions {
        string mission;
        uint numberOf;
    }
    struct MinCompletions {
        Completions minCompletions;
    }
    struct NftBalance {
        IERC721 nft;
        uint numberOf;
    }
    struct NftBalanceRequirement {
        NftBalance nftBalanceRequirement;
    }
    struct PrizeInfo {
        string name;
        uint prize;
    }
    struct Prize {
        Level unlocksAt;
        uint weighting;
        PrizeInfo info;
    }
    struct MissionConfig {
        MinLevel[] minLevels;
        MinCompletions[] minCompletions;
        NftBalanceRequirement[] nftBalanceRequirements;
        Prize[] prizes;
        uint entry;
        uint duration;
        uint cooldown;
        uint reward;
        uint maxCompletions;
    }
    event MissionConfigSet(string mission);
    event MissionEntered(uint tokenId, string mission, uint entryId, uint endsAt);
    event MissionFinished(uint tokenId, string mission, uint entryId, uint reward, PrizeInfo prize, uint cooldownEndsAt);
    function pause() external;
    function unpause() external;
    function setMissionConfig(string calldata mission, MissionConfig calldata missionConfig) external;
    function getMissionConfig(string calldata mission) external view returns(MissionConfig memory);
    function enterMission(uint tokenId, string calldata mission) external;
    function finishMission(uint tokenId) external;
}

contract Missions is IMissions, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    ILambos private _lambos;
    IWallet private _wallet;
    constructor(ILambos lambos, IWallet wallet) {
        _lambos = lambos;
        _wallet = wallet;
    }
    struct LamboMissionData {
        uint completions;
        uint nonce;
    }
    struct LamboData {
        bool inMission;
        string currentMission;
        uint missionEndsAt;
        uint cooldownEndsAt;
        mapping(string => LamboMissionData) missionData;
    }
    mapping(string => MissionConfig) private _missionConfigs;
    mapping(uint => LamboData) private _lamboData;
    function pause() external override onlyOwner {
        _pause();
    }
    function unpause() external override onlyOwner {
        _unpause();
    }
    function setMissionConfig(string calldata mission, MissionConfig calldata missionConfig) external override onlyOwner nonReentrant whenNotPaused {
        _missionConfigs[mission] = missionConfig;
        emit MissionConfigSet(mission);
    }
    function getMissionConfig(string calldata mission) external view override returns(MissionConfig memory) {
        return _missionConfigs[mission];
    }
    function enterMission(uint tokenId, string calldata mission) external override ownsLambo(tokenId) nonReentrant whenNotPaused {
        LamboData storage lamboData = _lamboData[tokenId];
        require(!lamboData.inMission, "Lambo is in a mission currently.");
        require(block.timestamp >= lamboData.cooldownEndsAt, "There is a pending cooldown for this lambo.");
        MissionConfig storage missionConfig = _missionConfigs[mission];
        IERC20(_wallet.hVilleAddress()).safeTransferFrom(msg.sender, address(_wallet), missionConfig.entry);
        MinLevel[] storage minLevels = missionConfig.minLevels;
        for(uint i; i < minLevels.length; i ++) {
            Level storage minLevel = minLevels[i].minLevel;
            require(_getValueOfStat(tokenId, minLevel.stat) >= minLevel.value, "Lambo does not meet all the minimum level requirements for this mission.");
        }
        MinCompletions[] storage minCompletions = missionConfig.minCompletions;
        for(uint i; i < minCompletions.length; i ++) {
            Completions storage minCompletion = minCompletions[i].minCompletions;
            require(lamboData.missionData[minCompletion.mission].completions >= minCompletion.numberOf, "Lambo does not meet all the minimum completions of other missions for this mission.");
        }
        NftBalanceRequirement[] storage nftBalanceRequirements = missionConfig.nftBalanceRequirements;
        for(uint i; i < nftBalanceRequirements.length; i ++) {
            NftBalance storage nftBalanceRequirement = nftBalanceRequirements[i].nftBalanceRequirement;
            require(nftBalanceRequirement.nft.balanceOf(msg.sender) >= nftBalanceRequirement.numberOf, "Owner of lambo does not meet all the nft requirements for this mission.");
        }
        lamboData.missionEndsAt = block.timestamp + missionConfig.duration;
        lamboData.currentMission = mission;
        lamboData.inMission = true;

        uint completions = lamboData.missionData[lamboData.currentMission].completions;
        require(completions < missionConfig.maxCompletions, "This lambo has completed this mission too many times.");
        emit MissionEntered(tokenId, mission, completions, lamboData.missionEndsAt);
    }
    function finishMission(uint tokenId) external override ownsLambo(tokenId) nonReentrant whenNotPaused {
        LamboData storage lamboData = _lamboData[tokenId];
        require(lamboData.inMission, "Lambo is not in a mission.");
        require(block.timestamp >= lamboData.missionEndsAt, "Lambo is still in the mission.");
        MissionConfig storage missionConfig = _missionConfigs[lamboData.currentMission];
        Prize[] storage prizes = missionConfig.prizes;
        uint totalWeightings;
        for(uint i; i < prizes.length; i ++) {
            Prize storage prize = prizes[i];
            Level storage prizeUnlocksAt = prize.unlocksAt;
            if(_getValueOfStat(tokenId, prizeUnlocksAt.stat) >= prizeUnlocksAt.value) {
                totalWeightings += prizes[i].weighting;
            }
        }
        PrizeInfo memory prizeInfo;
        for(uint i; i < prizes.length; i ++) {
            Prize storage prize = prizes[i];
            Level storage prizeUnlocksAt = prize.unlocksAt;
            if(_getValueOfStat(tokenId, prizeUnlocksAt.stat) >= prizeUnlocksAt.value) {
                uint randomNumber = uint(sha256(abi.encode(_useNonce(tokenId, lamboData.currentMission))));
                uint randomNumberUnderWeightings = randomNumber % totalWeightings;
                if(randomNumberUnderWeightings < prize.weighting) {
                    prizeInfo = prize.info;
                    break;
                }
                totalWeightings - prize.weighting;
            }
        }
        _wallet.withdrawAmount(msg.sender, missionConfig.reward + prizeInfo.prize);
        lamboData.inMission = false;
        lamboData.cooldownEndsAt = block.timestamp + missionConfig.cooldown;
        LamboMissionData storage lamboMissionData = lamboData.missionData[lamboData.currentMission];
        lamboMissionData.completions ++;
        emit MissionFinished(tokenId, lamboData.currentMission, lamboMissionData.completions - 1, missionConfig.reward, prizeInfo, lamboData.cooldownEndsAt);
    }
    function _getValueOfStat(uint tokenId, string storage key) private view returns(uint value) {
        bytes32 keyHash = sha256(bytes(key));
        ILambos.StatisticView[] memory statistics = _lambos.getAttributes(tokenId);
        for(uint i; i < statistics.length; i ++) {
            ILambos.StatisticView memory statistic = statistics[i];
            if(sha256(bytes(statistic.statistic)) == keyHash) {
                return statistic.value;
            }
        }
    }
    function _useNonce(uint tokenId, string storage mission) private returns(uint nonce) {
        LamboMissionData storage lamboMissionData = _lamboData[tokenId].missionData[mission];
        nonce = lamboMissionData.nonce;
        lamboMissionData.nonce ++;
    }
    modifier ownsLambo(uint tokenId) {
        require(msg.sender == _lambos.ownerOf(tokenId), "You don't own this lambo.");
        _;
    }
}