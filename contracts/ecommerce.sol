//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 < 0.9.0;

contract Ecommerce{

    struct Product{
        string title;
        string disc;
        address payable seller;
        uint productID;
        uint price;
        address buyer;
        bool delivered;
    }

    uint counter = 1;
    Product[] public products;
    address payable public manager;

    bool destroyed=false;

    modifier isNotDestroyed{
        require(!destroyed, "Contract does not exist");
        _;
    }

    constructor(){
        manager=payable(msg.sender);
    }

    event registered(string title,uint productID,address seller);
    event baught(uint productID, address buyer);
    event delivered(uint productID);

    function registerProduct(string memory _title, string memory _disc, uint _price) public isNotDestroyed{
        require(_price>0, "Price should be greater than Zero");
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.disc = _disc;
        tempProduct.price = _price * 10**18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productID = counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title,tempProduct.productID,msg.sender);
    }
    function buy(uint _productID) payable public isNotDestroyed{
        require(products[_productID-1].price==msg.value,"Please pay the exact price");
        require(products[_productID-1].seller!=msg.sender,"Seller can not buy the product");
        products[_productID-1].buyer = msg.sender;
        emit baught(_productID,msg.sender);
    }
    function delivery(uint _productID) public isNotDestroyed{
        require(products[_productID-1].buyer==msg.sender,"Only buyer can confirm");
        products[_productID-1].delivered=true;
        products[_productID-1].seller.transfer(products[_productID-1].price);
        emit delivered(_productID);
    }

    // function destroy() public{
    //     require(msg.sender==manager, "Only manager can call this function");
    //     selfdestruct(manager);
    // }

    function destroy() public isNotDestroyed{
        require(manager==msg.sender, "Only manager can call this function");
        manager.transfer(address(this).balance);
        destroyed=true;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }
}