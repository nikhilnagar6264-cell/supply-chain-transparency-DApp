// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Project {
    // Define the owner of the contract
    address public admin;

    // Product status in the supply chain
    enum Status { Created, InTransit, Delivered }

    // A product struct
    struct Product {
        uint256 id;
        string name;
        address currentOwner;
        Status status;
    }

    // Mapping from product ID to Product
    mapping(uint256 => Product) public products;

    // Counter for product IDs
    uint256 private nextProductId;

    // Events
    event ProductCreated(uint256 indexed id, string name, address indexed creator);
    event ProductTransferred(uint256 indexed id, address indexed from, address indexed to);
    event StatusUpdated(uint256 indexed id, Status newStatus);

    // Modifier to restrict to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    // Modifier to restrict to current owner of a product
    modifier onlyOwner(uint256 _productId) {
        require(products[_productId].currentOwner == msg.sender, "Not the owner of this product");
        _;
    }

    constructor() {
        admin = msg.sender;
        nextProductId = 1;
    }

    /// @notice Create a new product in the supply chain
    /// @param _name Name or description of the product
    function createProduct(string calldata _name) external onlyAdmin returns (uint256) {
        uint256 productId = nextProductId;
        products[productId] = Product({
            id: productId,
            name: _name,
            currentOwner: msg.sender,
            status: Status.Created
        });

        nextProductId += 1;

        emit ProductCreated(productId, _name, msg.sender);
        return productId;
    }

    /// @notice Transfer product to a new owner
    /// @param _productId ID of product
    /// @param _newOwner Address of new owner
    function transferOwnership(uint256 _productId, address _newOwner) external onlyOwner(_productId) {
        require(_newOwner != address(0), "Invalid new owner address");

        address previousOwner = products[_productId].currentOwner;
        products[_productId].currentOwner = _newOwner;

        emit ProductTransferred(_productId, previousOwner, _newOwner);
    }

    /// @notice Update the status of a product in its lifecycle
    /// @param _productId ID of product
    /// @param _newStatus New status to set
    function updateStatus(uint256 _productId, Status _newStatus) external onlyOwner(_productId) {
        products[_productId].status = _newStatus;

        emit StatusUpdated(_productId, _newStatus);
    }

    /// @notice Get product details
    /// @param _productId ID of product
    /// @return name, currentOwner, status
    function getProduct(uint256 _productId) external view returns (string memory, address, Status) {
        Product memory p = products[_productId];
        return (p.name, p.currentOwner, p.status);
    }
}

