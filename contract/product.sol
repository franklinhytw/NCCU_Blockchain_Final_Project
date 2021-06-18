// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

contract ProductTraceability {

    /**
    * @dev 產品
    */
    struct Product {
        string Name; //名稱
        string Description; //敘述
        string Producer; //製造商名稱
        string Location; //製造地點
        string[] ComponentList; //這個產品的所有零件Key值(ComponentId)
        mapping(string => Component) ComponentStructs; //零件
        uint256 CreationDate; //製造時間
        bool Exist;
    }

    /**
    * @dev 零件
    */
    struct Component {
        string Name; //名稱
        string Description; //敘述
        string Producer; //製造商名稱
        string Location; //製造地點
        string ComponentType; //種類
        uint256 CreationDate; //製造時間
    }
    
    /**
    * @dev Mapping that define the storage of a product
    */
    mapping(string  => Product) private StorageProduct;
    string[] StorageProductList; // list of question keys so we can enumerate them
    
    /**
    * @dev Declare events according the supply chain operations:
    */
    event CreateProduct(address addressProducer, string productId, string Producer, uint256 CreationDate);
    event CreationReject(address addressProducer, string productId, string RejectMessage);
    event CreateProductComponent(address addressProducer, string productId, string componentId, string Producer, uint256 CreationDate);
    
    /**
    * @dev 建立產品:
    * productId：序號 RF8M20D1JAQ 之類的 反正就一個序號
    * name:產品名稱 Samsung Galaxy S10
    * description:產品敘述 The greatest Android phone in 2020
    * producer:製造商 Samsung
    * location:製造地點 Pusan,Korea,
    */
    function creationProduct(string memory productId, string memory name, string memory description, string memory producer, string memory location) public 
    {
        if (StorageProduct[productId].Exist)
        {
            emit CreationReject(msg.sender, productId, "Product con this id already exist");
            return;
        }
 
        StorageProduct[productId].Name = name;
        StorageProduct[productId].Description = description;
        StorageProduct[productId].Producer = producer;
        StorageProduct[productId].Location = location;
        StorageProduct[productId].CreationDate = block.timestamp;
        StorageProduct[productId].Exist = true;
        StorageProductList.push(productId);
    
        emit CreateProduct(msg.sender, productId, producer, block.timestamp);
    }
    
    /**
    * @dev 取得產品資訊
    */
    function getProduct(string memory productId) public view 
        returns  (string memory name, string memory description, string memory producer, string memory location, uint256 creationDate, uint compnentCount)
    {
    
        return (StorageProduct[productId].Name, 
                StorageProduct[productId].Description,
                StorageProduct[productId].Producer, 
                StorageProduct[productId].Location, 
                StorageProduct[productId].CreationDate,
                StorageProduct[productId].ComponentList.length);
    }
    
    /**
    * @dev 取得所有產品資訊
    */
    function getAllProductId() public view returns(string[] memory)
    {
    
        return StorageProductList;
    }
    
    /**
    * @dev 建立產品的零件
    * productId：產品序號
    * componentId: 零件序號 不要和產品序號長一樣就好 反正就一個序號
    * name:零件名稱 S888
    * description:零件敘述 Qualcomm CPU
    * producer:製造商 Qualcomm
    * location:製造地點 California,USA
    * componentType:零件類型 CPU
    */
    function creationProductComponent(string memory productId, string memory componentId, string memory name, string memory description, string memory producer, string memory location, string memory componentType) public
    {
        StorageProduct[productId].ComponentList.push(componentId);
        StorageProduct[productId].ComponentStructs[componentId].Name = name;
        StorageProduct[productId].ComponentStructs[componentId].Description = description;
        StorageProduct[productId].ComponentStructs[componentId].Producer = producer;
        StorageProduct[productId].ComponentStructs[componentId].Location = location;
        StorageProduct[productId].ComponentStructs[componentId].ComponentType = componentType;
        StorageProduct[productId].ComponentStructs[componentId].CreationDate = block.timestamp;
        
        emit CreateProductComponent(msg.sender, productId, componentId, producer, block.timestamp);
    }

    /**
    * @dev 取得產品的零件數量
    * 因為Solidity不能回傳物件也不能回傳陣列
    * 所以只能在呼叫端先取得一個產品有多少零件(getProductComponentCount或是getProduct的compnentCount欄位)
    * 再一個個取出該零件的Id(getProductComponentIdAtIndex)
    * 再一個個用該零件的Id取出零件資訊(getProductComponent)
    */
    function getProductComponentCount(string memory productId) public view
        returns(uint componentCount)
    {
        return(StorageProduct[productId].ComponentList.length);
    }
    
    /**
    * @dev 取得產品的零件Id
    */
    function getProductComponentIdAtIndex(string memory productId, uint row) public view
        returns(string memory componentId)
    {
        return(StorageProduct[productId].ComponentList[row]);
    }  
    
    /**
    * @dev 取得產品的零件
    */
    function getProductComponent(string memory productId, string memory componentId) public view
        returns(string memory name, string memory description, string memory producer, string memory location, string memory componentType, uint256 creationDate)
    {
        return(
            StorageProduct[productId].ComponentStructs[componentId].Name,
            StorageProduct[productId].ComponentStructs[componentId].Description,
            StorageProduct[productId].ComponentStructs[componentId].Producer,
            StorageProduct[productId].ComponentStructs[componentId].Location,
            StorageProduct[productId].ComponentStructs[componentId].ComponentType,
            StorageProduct[productId].ComponentStructs[componentId].CreationDate);
    }

}