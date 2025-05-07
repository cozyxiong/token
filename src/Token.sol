// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Token is Initializable, OwnableUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable {

    string private constant NAME = "CozyXiongToken";
    string private constant SYMBOL = "CXT";

    uint256 public constant MIN_MINT_INTERVAL = 365 days;
    uint256 public constant MINT_CAP_DENOMINATOR = 10_000;
    uint256 public constant MAX_MINT_CAP_NUMERATOR = 200;

    uint256 public nextMintTime;
    uint256 public mintCapNumerator;

    error ImproperlyInitialized();
    error MintCapNumeratorTooLarge(uint256 mintCapNumerator, uint256 maxMintCapNumerator);
    error MintAmountTooLarge(uint256 mintAmount, uint256 maxMintAmount);
    error NextMintTimeNotReached(uint256 mintTime, uint256 nextMintTime);

    event MintCapNumeratorChanged(address indexed by, uint256 previousMintCapNumerator, uint256 nowMintCapNumerator);

    constructor() {
        _disableInitializers();
    }

    function initialize(address _owner, uint256 _initialSupply) public initializer {
        if (_owner == address(0) || _initialSupply == 0) revert ImproperlyInitialized();

        __Ownable_init(_owner);

        __ERC20_init(NAME, SYMBOL);
        __ERC20Burnable_init();
        _mint(_owner, _initialSupply);
        nextMintTime = block.timestamp + MIN_MINT_INTERVAL;

        _transferOwnership(_owner);
    }

    function mint(address _minter, uint256 _amount) public onlyOwner {
        uint256 maximumMintAmount = (totalSupply() * mintCapNumerator) / MINT_CAP_DENOMINATOR;
        if (_amount > maximumMintAmount) {
            revert MintAmountTooLarge(_amount, maximumMintAmount);
        }
        if (block.timestamp < nextMintTime) {
            revert NextMintTimeNotReached(block.timestamp, nextMintTime);
        }
        super._mint(_minter, _amount);
    }

    function setMintCapNumerator(uint256 _mintCapNumerator) public onlyOwner {
        if (_mintCapNumerator > MAX_MINT_CAP_NUMERATOR) {
            revert MintCapNumeratorTooLarge(_mintCapNumerator, MAX_MINT_CAP_NUMERATOR);
        }
        emit MintCapNumeratorChanged(msg.sender, mintCapNumerator, _mintCapNumerator);
        mintCapNumerator = _mintCapNumerator;
    }
}
