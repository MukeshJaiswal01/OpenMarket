pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "sc.sol";


contract SimpleMarketplace {
    Supplychain sc;
    
    enum StateType { 
      ItemAvailable,
      OfferPlaced,
      Accepted
    }
    
    struct product_info{
        
        string product_name;
        uint price;
    }
        
    address item_origin;
    product_info Product;
    string [] public listed_products;
    mapping(string => uint) all_product_with_price;
    mapping( string => address payable) public item_instanceOwner;
    mapping(string => StateType) public item_state;
    
   // mapping(string => string []) item_history;
    
  
  
    function Product_on_Sale(string memory description, uint price) public
    {
       address payable InstanceOwner = msg.sender;
        listed_products.push(description);
        all_product_with_price[description] = price;
        item_state[description] = StateType.ItemAvailable;
        item_instanceOwner[description] = InstanceOwner;
        
    }
    
    function show_all_product() public  view returns(string[] memory, uint [] memory){
        
      string [] memory product_name = new string[](listed_products.length);
      uint [] memory product_price = new uint[](listed_products.length);
        
       for(uint i = 0; i < listed_products.length; i++){
           
           product_name[i] = listed_products[i];
           product_price[i]= price(product_name[i]);
       }
       
    }
    
    function price(string memory item) view  public returns(uint){
        
        return all_product_with_price[item];
    }

    function buy_item(string memory item , int offerPrice) public 
    {
        if (offerPrice == 0)
        {
            revert();
        }

        if (item_state[item] != StateType.ItemAvailable)
        {
            revert();
        }
        
        if (item_instanceOwner[item] == msg.sender)
        {
            revert();
        }

        item_instanceOwner[item] = msg.sender;
    
        item_state[item] = StateType.OfferPlaced;
    }
    
    function get_item_origin( string memory item) public view returns(
        address [] memory  , uint [] memory  , string [] memory){
            
            return sc.get_item_history(item);
        }
        
        

    function Reject(string memory item) public
    {
        if ( item_state[item] != StateType.OfferPlaced )
        {
            revert();
        }

        if (item_instanceOwner[item] != msg.sender)
        {
            revert();
        }

        item_instanceOwner[item] = 0x0000000000000000000000000000000000000000;
        item_state[item] = StateType.ItemAvailable;
    }
    
    

    function AcceptOffer(string memory item) public payable
    {
        if ( item_instanceOwner[item] != msg.sender )
        {
            revert();
        }
        if(msg.value == 0){
            revert();
        }
        
        uint _price = msg.value;
        uint commission = _price - (( _price) *5 / 100);
        uint money_to_vendor = commission;
        item_instanceOwner[item].transfer(money_to_vendor);
        item_instanceOwner[item] = msg.sender;
        item_state[item] = StateType.Accepted;
        
        
    }
    
    function balance_of_contract() public  view returns(uint){
        return address(this).balance;
    }
}
