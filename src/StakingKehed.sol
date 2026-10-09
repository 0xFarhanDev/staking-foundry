// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract StakingKehed is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuard,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    IERC20 public khdToken;
    address public feeCollector;
    uint256 public constant LOCK_DURATION = 60 seconds;
    uint256 public maxStakePerUser;
    uint256 public withdrawalFeePercentage;

    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakeTimestamp;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastClaimTimestamp;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 feeAmount, uint256 timestamp);
    event RewardClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event Compounded(address indexed user, uint256 amount, uint256 timestamp);

    constructor() {
        _disableInitializers();
    }

    function initialize(address _tokenAddress, address _admin) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        khdToken = IERC20(_tokenAddress);
        feeCollector = _admin;

        maxStakePerUser = 5000 * 10 ** 18;
        withdrawalFeePercentage = 1;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(PAUSER_ROLE, _admin);
        _grantRole(WITHDRAWER_ROLE, _admin);
    }

    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function emergancyWithdrawToken(uint256 amount) external onlyRole(WITHDRAWER_ROLE) {
        require(khdToken.balanceOf(address(this)) >= amount, "Saldo token tidak cukup");
        khdToken.transfer(msg.sender, amount);
    }

    function stake(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakedBalances[msg.sender] + _amount <= maxStakePerUser, "Kebanyakan KHD.");

        stakeTimestamp[msg.sender] = block.timestamp;

        if (stakedBalances[msg.sender] == 0) {
            lastClaimTimestamp[msg.sender] = block.timestamp;
        }

        khdToken.transferFrom(msg.sender, address(this), _amount);
        stakedBalances[msg.sender] += _amount;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function calculateRewards(address user) public view returns (uint256) {
        if (stakedBalances[user] == 0) return 0;
        return (stakedBalances[user] * 10) / 100;
    }

    function claimReward() external whenNotPaused nonReentrant {
        uint256 reward = (stakedBalances[msg.sender] * 10) / 100;
        require(reward > 0, "Lu gak punya saldo yang di stake Blegug");
        require(khdToken.balanceOf(address(this)) >= reward, "Saldo reward staking tidak cukup");
        require(
            block.timestamp >= lastClaimTimestamp[msg.sender] + 60 seconds,
            "Sabar Blegugg, Belum 60 detik udah mau Claim lagi aja"
        );

        lastClaimTimestamp[msg.sender] = block.timestamp;

        khdToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward, block.timestamp);
    }

    function autoCompound() external whenNotPaused nonReentrant {
        uint256 reward = (stakedBalances[msg.sender] * 10) / 100;
        require(reward > 0, "Gak ada reward yang di-compound");
        require(khdToken.balanceOf(address(this)) >= reward, "Saldo reward staking tidak cukup");
        require(
            block.timestamp >= lastClaimTimestamp[msg.sender] + 60 seconds, "Kalo mau Sugih Harus Sabar,Belum 60 detik"
        );

        lastClaimTimestamp[msg.sender] = block.timestamp;

        stakedBalances[msg.sender] += reward;

        emit Compounded(msg.sender, reward, block.timestamp);
    }

    function updateMaxStake(uint256 _newMax) external onlyRole(DEFAULT_ADMIN_ROLE) {
        maxStakePerUser = _newMax;
    }

    function setFeeCollector(address _newFeeCollector) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_newFeeCollector != address(0), "Fee collector cannot be zero address");
        feeCollector = _newFeeCollector;
    }

    function withdraw() external whenNotPaused nonReentrant {
        uint256 stakedAmount = stakedBalances[msg.sender];
        require(stakedAmount > 0, "Saldo Kurang Blegug");

        uint256 reward = 0;
        if (block.timestamp >= lastClaimTimestamp[msg.sender] + 60 seconds) {
            reward = calculateRewards(msg.sender);
        }

        stakedBalances[msg.sender] = 0;
        lastClaimTimestamp[msg.sender] = 0;

        uint256 feeAmount = (stakedAmount * withdrawalFeePercentage) / 100;
        uint256 amountToUser = stakedAmount - feeAmount;

        require(khdToken.transfer(feeCollector, feeAmount), "Gagal Kirim Pajak ke Owner");
        require(khdToken.transfer(msg.sender, amountToUser), "Gagal kembaliin Modal");

        if (reward > 0) {
            require(khdToken.transfer(msg.sender, reward), "Gagal kirim reward");
            emit RewardClaimed(msg.sender, reward, block.timestamp);
        }

        emit Withdrawn(msg.sender, amountToUser, feeAmount, block.timestamp);
    }
}
