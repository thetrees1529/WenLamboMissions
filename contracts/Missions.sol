//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "utils/contracts/payments/ERC20Payments.sol";
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
interface IToolboxes {
    struct ToolboxView {
        uint256 toolboxToken;
        bool isOpened;
        bool isUsed;
        uint8 upgradeType;
        uint8 upgradeRarity;
        uint256 upgradeAmount;
        address owner;
    }
    function airdropToolbox(address to) external;
    function getToolboxes(address _addr) external view returns (ToolboxView[] memory);
}
interface IMetadata {

    event MetadataSet(uint nft, string key, string value);

    struct MetadataInput {
        uint nft;
        string key;
        string value;
    }

    function bulkSetMetadata(MetadataInput[] calldata inputs) external;

    function setMetadata(MetadataInput calldata input) external;

    function getMetadata(uint nft, string calldata key) external view returns(string memory);

}
interface IGarageManager {  
    struct GarageDataView {
        uint256 speed; // hVille earning speed (per day)
        uint256 unlocked;
        uint256 locked;
        uint256 lockedInterest;
        uint256 totalSpent;
        uint256 totalEverClaimed;
        uint8 pitCrew; // 0 or 1
        uint8 crewChief; // 0 -> 3
        uint8 mechanic; // 0 -> 3
        uint8 gasman; // 0 -> 3
        uint8 tireChanger; // 0 -> 3
    }
    enum UT {pit, chief, mech, gas, tire}
    function getTokenAttributes(uint256 _tokenId) external view returns (GarageDataView memory);
}
contract Missions is Ownable, ReentrancyGuard, ERC20Payments {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    struct MinLevel {
        string stat;
        uint value;
    }
    struct RequiredAttribute {
        string key;
        string value;
    }
    struct RequiredGarageLevel {
        IGarageManager.UT attr;
        uint8 level;
    }
    struct MinCompletions {
        uint missionId;
        uint numberOf;
    }
    struct NftBalanceRequirement {
        IERC721 nft;
        uint numberOf;
    }
    struct Requirement {
        RequiredAttribute[] requiredAttributes;
        MinLevel[] minLevels;
        MinCompletions[] minCompletions;
        NftBalanceRequirement[] nftBalanceRequirements;
        RequiredGarageLevel[] requiredGarageLevels;
    }
    struct NftReward {
        IERC721Enumerable collection;
        uint numberOf;
    }
    struct NftRewardConfig {
        NftReward nftReward;
        address holder;
    }
    struct Nft {
        IERC721 collection;
        uint tokenId;
    }
    struct Toolbox {
        uint8 upgradeType;
        uint8 upgradeRarity;   
        uint256 upgradeAmount;
    }
    struct Pouch {
        IERC20 token;
        uint value;
    }
    struct PouchConfig {
        Pouch pouch;
        address holder;
    }
    struct EntryPouchConfig {
        Pouch pouch;
        address receiver;
    }
    struct RewardItems {
        uint prize;
        NftRewardConfig[] nfts;
        PouchConfig[] pouches;
        uint toolboxes;
    }
    struct Reward {
        string name;
        RewardItems items;
    }
    struct RewardViewItems {
        uint prize;
        Nft[] nfts;
        Pouch[] pouches;
        Toolbox[] toolboxes;
    }
    struct RewardView {
        string name;
        RewardViewItems items;
    }
    struct PrizeView {
        string name;
        uint prizeIndex;
        RewardViewItems items;
    }
    struct PrizeOption {
        uint weighting;
        Reward prize;
    }
    struct PrizeOptionView {
        uint prizeIndex;
        PrizeOption option;
    }
    struct PrizeConfig {
        Requirement[] requirements;
        uint maxHits;
        uint weighting;
        Reward prize;
    }
    struct ResultView {
        RewardView rewards;
        PrizeView prizes;
    }
    struct LamboMissionData {
        uint completions;
        uint totalEarnings;
        mapping(uint => uint) prizeHits;
    }
    struct LamboData {
        uint totalEarnings;
        bool hasEntry;
        uint entryId;
    }
    struct MissionConfig {
        string meta;
        Requirement[] requirements;
        Reward reward;
        PrizeConfig[] prizes;
        uint duration;
        uint cooldown;
        uint maxCompletions;
        uint entry;
        EntryPouchConfig[] erc20Entries;
    }
    struct MissionView {
        bool removed;
        MissionConfig config;
    }
    struct MissionData {
        MissionConfig config;
        bool removed;
        mapping(uint => LamboMissionData) lamboMissionData;
    }
    struct MissionEntry {
        uint tokenId;
        uint missionId;
        uint endsAt;
        bool ended;
        uint cooldownEndsAt;
        ResultView result;
    }

    constructor(ILambos collection, IWallet wallet, IMetadata metadata, IToolboxes toolboxes, IGarageManager garageManager) ERC20Payments(IERC20(wallet.hVilleAddress())) {
        _collection = collection;
        _wallet = wallet;
        _metadata = metadata;
        _toolboxes = toolboxes;
        _garageManager = garageManager;
    }

    ILambos private _collection;
    IWallet private _wallet;
    IMetadata private _metadata;
    IToolboxes private _toolboxes;
    IGarageManager private _garageManager;

    MissionData[] private _missions;
    MissionEntry[] private _entries;
    mapping(uint => LamboData) private _lambos;

    Counters.Counter private _entryIds;

    function setPayees(ERC20Payments.Payee[] calldata payees) external onlyOwner {
        _setPayees(payees);
    }

    event MissionCreated(uint missionId);
    function createMission(MissionConfig calldata config) external nonReentrant onlyOwner returns(uint missionId) {
        missionId = _missions.length;
        MissionData storage mission = _missions.push();
        mission.config = config;
        emit MissionCreated(missionId);
    }

    event MissionRemoved(uint missionId);
    function removeMission(uint missionId) external nonReentrant onlyOwner {
        MissionData storage mission = _missions[missionId];
        require(!mission.removed, "Already removed.");
        mission.removed = true;
        emit MissionRemoved(missionId);
    }

    function getMission(uint missionId) external view returns(MissionView memory) {
        MissionData storage mission = _missions[missionId];
        return MissionView(mission.removed, mission.config);
    }

    event MissionEntered(uint entryId, uint missionId, uint tokenId);
    function enterMission(uint tokenId, uint missionId) external nonReentrant returns(uint entryId) {
        address account = msg.sender;

        MissionData storage mission = _missions[missionId];
        LamboMissionData storage lamboMissionData = mission.lamboMissionData[tokenId];
        MissionConfig storage missionConfig = mission.config;
        LamboData storage lambo = _lambos[tokenId];

        _requireOwnsLambo(account, tokenId);
        require(!mission.removed, "Mission was removed.");
        require(lamboMissionData.completions < missionConfig.maxCompletions);
        require(_meetsRequirements(account, tokenId, missionConfig.requirements), "Requirements not met.");

        _takePayment(account, missionConfig.entry);
        _takeERC20Payments(account, missionConfig.erc20Entries);

        entryId = _entries.length;

        if(lambo.hasEntry) {
            MissionEntry storage lastEntry = _entries[lambo.entryId];
            require(lastEntry.ended, "Last mission entry not finished.");
            require(block.timestamp >= lastEntry.cooldownEndsAt, "Last mission cooldown not over.");
        } else {
            lambo.hasEntry = true;
        }

        lambo.entryId = entryId;

        MissionEntry storage missionEntry = _entries.push();
        missionEntry.endsAt = block.timestamp + missionConfig.duration;
        missionEntry.missionId = missionId;
        missionEntry.tokenId = tokenId;

        emit MissionEntered(entryId, missionId, tokenId);
    }

    event MissionFinished(uint entryId);
    function endMission(uint entryId) external nonReentrant {
        address account = msg.sender;

        MissionEntry storage entry = _entries[entryId];
        MissionData storage mission = _missions[entry.missionId];
        LamboMissionData storage lamboMissionData = mission.lamboMissionData[entry.tokenId];
        MissionConfig storage missionConfig = mission.config;
        PrizeConfig[] storage prizeConfigs = missionConfig.prizes;
        LamboData storage lambo = _lambos[entry.tokenId];

        require(!entry.ended, "Mission entry already ended.");
        require(block.timestamp >= entry.endsAt, "Mission not over.");
        _requireOwnsLambo(account, entry.tokenId);

        PrizeOptionView[] memory qualifiedPrizes = new PrizeOptionView[](prizeConfigs.length);
        uint i;
        uint totalWeighting;
        for(uint j; j < prizeConfigs.length; j ++) {
            PrizeConfig storage prizeConfig = prizeConfigs[j];
            if(
                _meetsRequirements(account, entry.tokenId, prizeConfig.requirements) &&
                lamboMissionData.prizeHits[j] < prizeConfig.maxHits
            ) {
                qualifiedPrizes[i] = PrizeOptionView(j, PrizeOption(prizeConfig.weighting, prizeConfig.prize));
                totalWeighting += prizeConfig.weighting;
                i ++;
            }
        }
        PrizeView memory prizes;
        uint rInt = uint(sha256(abi.encode(entry.missionId, entry.tokenId, lamboMissionData.completions)));
        for(uint j; j < i; j ++) {
            PrizeOptionView memory prizeOptionView = qualifiedPrizes[j];
            PrizeOption memory prizeOption = prizeOptionView.option;
            uint res = rInt % totalWeighting;
            if(res < prizeOption.weighting) {
                RewardViewItems memory prizeViewItems = _dispenseRewardItems(account, prizeOption.prize.items); 
                prizes = PrizeView(prizeOption.prize.name, prizeOptionView.prizeIndex, prizeViewItems);
                lamboMissionData.prizeHits[prizeOptionView.prizeIndex] ++;
                break;
            }
            totalWeighting -= prizeOption.weighting;
        }

        RewardViewItems memory rewardViewItems = _dispenseRewardItems(account, missionConfig.reward.items);
        entry.ended = true;
        entry.cooldownEndsAt = entry.endsAt + missionConfig.cooldown;
        entry.result = ResultView({
            prizes: prizes,
            rewards: RewardView(missionConfig.reward.name, rewardViewItems)
        });

        uint totalEarnings = prizes.items.prize + rewardViewItems.prize;
        lambo.totalEarnings += totalEarnings;
        lamboMissionData.totalEarnings += totalEarnings;

        lamboMissionData.completions ++;

        emit MissionFinished(entryId);
    }

    function abortMission(uint entryId) external nonReentrant {
        address account = msg.sender;
        MissionEntry storage entry = _entries[entryId];
        require(!entry.ended, "Mission entry already ended.");
        _requireOwnsLambo(account, entry.tokenId);
        entry.ended = true;
        emit MissionFinished(entryId);
    }

    function getEntriesLength() external view returns(uint) {
        return _entries.length;
    }

    function getEntry(uint entryId) external view returns(MissionEntry memory) {
        return _entries[entryId];
    }

    function getRecentEntryId(uint tokenId) external view returns(uint) {
        LamboData storage lambo = _lambos[tokenId];
        require(lambo.hasEntry, "Lambo has never entered a mission.");
        return lambo.entryId;
    }

    function getTotalEarnings(uint tokenId) external view returns(uint) {
        return _lambos[tokenId].totalEarnings;
    }

    function getTotalEarningsByMission(uint tokenId, uint missionId) external view returns(uint) {
        return _missions[missionId].lamboMissionData[tokenId].totalEarnings;
    }

    function getEntryCount(uint tokenId, uint missionId) external view returns(uint) {
        return _missions[missionId].lamboMissionData[tokenId].completions;
    }
 
    function _dispenseRewardItems(address to, RewardItems memory items) private returns(RewardViewItems memory rewardView) {
        return RewardViewItems({
                prize: _dispenseHville(to, items.prize),
                toolboxes: _dispenseToolboxes(to, items.toolboxes),
                pouches: _dispensePouches(to, items.pouches),
                nfts: _dispenseNftRewards(to, items.nfts)
            });

    }

    function _dispenseHville(address to, uint value) private returns(uint) {
        _wallet.withdrawAmount(to, value);
        return value;
    }

    function _dispenseToolboxes(address to, uint numberOf) private returns(Toolbox[] memory toolboxes) {
        toolboxes = new Toolbox[](numberOf);
        for(uint i; i < numberOf; i ++) {
            toolboxes[i] = _dispenseToolbox(to);
        }
    }
    function _dispenseToolbox(address to) private returns(Toolbox memory) {
        _toolboxes.airdropToolbox(to);
        IToolboxes.ToolboxView[] memory toolboxViews = _toolboxes.getToolboxes(to);
        IToolboxes.ToolboxView memory toolboxView = toolboxViews[toolboxViews.length - 1];
        return Toolbox({
            upgradeType: toolboxView.upgradeType,
            upgradeRarity:toolboxView.upgradeRarity,
            upgradeAmount:toolboxView.upgradeAmount
        });
    }

    Nft[] private _nfts;
    function _dispenseNftRewards(address to, NftRewardConfig[] memory nftRewards) private returns(Nft[] memory nfts) {
        for(uint i ; i < nftRewards.length; i ++){
            Nft[] memory temp = _dispenseNftReward(to, nftRewards[i]);
            for(uint j; j < temp.length; j++) {
                _nfts.push(temp[j]);
            }
        }
        nfts = _nfts;
        delete _nfts;
    }

    function _dispenseNftReward(address to, NftRewardConfig memory nftReward) private returns(Nft[] memory nfts) {
        nfts = new Nft[](nftReward.nftReward.numberOf);
        for(uint i; i < nftReward.nftReward.numberOf; i ++) {
            uint tokenId = nftReward.nftReward.collection.tokenOfOwnerByIndex(nftReward.holder,0);
            nftReward.nftReward.collection.safeTransferFrom(nftReward.holder, to, tokenId);
            nfts[i] = Nft(nftReward.nftReward.collection, tokenId);
        }

    }

    function _dispensePouches(address to, PouchConfig[] memory pouches) private returns(Pouch[] memory pouchViews){
        pouchViews = new Pouch[](pouches.length);
        for(uint i; i < pouches.length; i ++) {
            pouchViews[i] = _dispensePouch(to, pouches[i]);
        }
    }

    function _dispensePouch(address to, PouchConfig memory pouch) private returns(Pouch memory) {
        pouch.pouch.token.transferFrom(pouch.holder,to, pouch.pouch.value);
        return pouch.pouch;
    }

    function _takePayment(address from, uint value) private {
        IERC20(_wallet.hVilleAddress()).safeTransferFrom(from, address(this), value);
        _makePayment(value);
    }

    function _takeERC20Payments(address from, EntryPouchConfig[] storage entryPouches) private {
        for(uint i; i < entryPouches.length; i ++) _takeERC20Payment(from, entryPouches[i]);
    }

    function _takeERC20Payment(address from, EntryPouchConfig storage entryPouch) private {
        entryPouch.pouch.token.safeTransferFrom(from,entryPouch.receiver, entryPouch.pouch.value);
    }

    function _meetsRequirements(address account, uint tokenId, Requirement[] storage requirements) private view returns(bool) {
        for(uint i; i < requirements.length; i ++) {
            if (!_meetsRequirement(account, tokenId, requirements[i])) return false;
        }
        return true;
    }

    function _meetsRequirement(address account, uint tokenId, Requirement storage requirement) private view returns(bool) {
        if (
            !_hasAnyOfRequiredAttributes(tokenId, requirement.requiredAttributes) &&
            !_meetsAnyOfRequiredGarageLevels(tokenId, requirement.requiredGarageLevels) &&
            !_meetsAnyOfNftBalanceRequirements(account, requirement.nftBalanceRequirements) &&
            !_meetsAnyOfMinCompletions(tokenId, requirement.minCompletions) &&
            !_meetsAnyOfMinLevels(tokenId, requirement.minLevels)
        ) return false;
        else return true;
    }
    
    function _hasAnyOfRequiredAttributes(uint tokenId, RequiredAttribute[] storage requiredAttributes) private view returns(bool) {
        for(uint i; i < requiredAttributes.length; i ++) {
            if(_hasRequiredAttribute(tokenId, requiredAttributes[i])) return true;
        }
        return false;
    }
    function _hasRequiredAttribute(uint tokenId, RequiredAttribute storage requiredAttribute) private view returns(bool) {
            return sha256(bytes(_metadata.getMetadata(tokenId, requiredAttribute.key))) == sha256(bytes(requiredAttribute.value));
    }
    function _meetsAnyOfRequiredGarageLevels(uint tokenId, RequiredGarageLevel[] storage requiredGarageLevels) private view returns(bool) {
        for(uint i; i < requiredGarageLevels.length; i ++) {
            if (_meetsRequiredGarageLevel(tokenId, requiredGarageLevels[i])) return true;
        }
        return false;
    }
    function _meetsRequiredGarageLevel(uint tokenId, RequiredGarageLevel storage requiredGarageLevel) private view returns(bool) {
            IGarageManager.UT uT = requiredGarageLevel.attr;
            IGarageManager.GarageDataView memory data = _garageManager.getTokenAttributes(tokenId);
            uint level;

            if(uT == IGarageManager.UT.pit) level = data.pitCrew;
            else if(uT == IGarageManager.UT.chief) level = data.crewChief;
            else if(uT == IGarageManager.UT.mech) level = data.mechanic;
            else if(uT == IGarageManager.UT.gas) level = data.gasman;
            else if(uT == IGarageManager.UT.tire) level = data.tireChanger;

            return level >= requiredGarageLevel.level;
    }
    function _meetsAnyOfNftBalanceRequirements(address account, NftBalanceRequirement[] storage nftBalanceRequirements) private view returns(bool) {
        for(uint i; i < nftBalanceRequirements.length; i ++) {
            if(_meetsNftBalanceRequirement(account, nftBalanceRequirements[i])) return true;
        }
        return false;
    }
    function _meetsNftBalanceRequirement(address account, NftBalanceRequirement storage nftBalanceRequirement) private view returns(bool) {
        return nftBalanceRequirement.nft.balanceOf(account) >= nftBalanceRequirement.numberOf;
    }
    function _meetsAnyOfMinCompletions(uint tokenId, MinCompletions[] storage minCompletions) private view returns(bool) {
        for(uint i; i < minCompletions.length; i ++) {
            if(_meetsMinCompletion(tokenId, minCompletions[i])) return true;
        }
        return false;
    }
    function _meetsMinCompletion(uint tokenId, MinCompletions storage minCompletion) private view returns(bool) {
        return _missions[minCompletion.missionId].lamboMissionData[tokenId].completions >= minCompletion.numberOf;
    }
    function _meetsAnyOfMinLevels(uint tokenId, MinLevel[] storage minLevels) private view returns(bool) {
        for(uint i; i < minLevels.length; i ++) {
            if(_meetsMinLevel(tokenId, minLevels[i])) return true;
        }
        return false;
    }
    function _meetsMinLevel(uint tokenId, MinLevel storage minLevel) private view returns(bool) {
        return _getValueOfStat(tokenId, minLevel.stat) >= minLevel.value;
    }
    function _getValueOfStat(uint tokenId, string storage key) private view returns(uint value) {
        bytes32 keyHash = sha256(bytes(key));
        ILambos.StatisticView[] memory statistics = _collection.getAttributes(tokenId);
        for(uint i; i < statistics.length; i ++) {
            ILambos.StatisticView memory statistic = statistics[i];
            if(sha256(bytes(statistic.statistic)) == keyHash) {
                return statistic.value;
            }
        }
    }


    function _requireOwnsLambo(address account, uint tokenId) private view {
        require(_collection.ownerOf(tokenId) == account, "Not owner of lambo.");
    }

}
