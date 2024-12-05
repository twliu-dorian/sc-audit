contract GameToken is IERC20 { // ERC20 interface
    // hardcoded address of the GameTokenManager contract
    address immutable _gameManager = 
        0x74cf968bde151a94613a6b1d538E2BBEF974ff;

    ... // standard ERC20 variables such as totalSupply, balanceOf[]

    // Constructor
    constructor() {
        totalSupply = 894579383883348345739534; // A fixed initial supply
        // All tokens initially owned by game manager
        balanceOf[_gameManager] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) 
        external 
        returns (bool)
    {
        GameTokenManager manager = GameTokenManager(_gameManager);

        balanceOf[recipient] += amount;
        // Make sure the game manager (contract) approves this!
        require(manager.approveTransfer(msg.sender, amount, recipient) == true);
        balanceOf[msg.sender] -= amount;
        return true;
    }

    ... // other methods omitted
}

contract GameTokenRegistry {
    // hardcoded hash of GameToken contract bytecode
    bytes32 _knownTokenContractHash = 
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7fad8045d85a470;

    mapping(address => uint256) private _registeredContracts;

    // Allow external callers to add a new GameToken contract to the registry.
    // We must check that it’s really a GameToken, using EXTCODEHASH.
    function registerNewToken(GameToken newToken) external {
        // We want to be sure this contract truly is a GameToken, so we’ll
        // check its code hash
        bytes32 codeHash;
        assembly { codeHash := extcodehash(address(newToken)) }
        require (codeHash == _knownTokenContractHash);
        _registeredContracts[address(newToken)] = 1; // add to registry
    }
}
