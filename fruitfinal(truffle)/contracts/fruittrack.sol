pragma solidity ^0.4.0;

contract fruittrack{
    address owner;

    event Register(string name);

    mapping(string=>fruit) goods;
    mapping(address=>farmer) farm;
    mapping(address=>distributor) distri;
    mapping(address=>market) mark;
    mapping(uint=>shipment) ship;

    struct fruit{
        string name;        
        string desc;
        address farmer_;
        uint256 harv_date;
        uint quantity;

        address[2] partner;
        uint256[2] sendDate;
        uint256[2] receiveDate;
        uint16 status;
    }

    // struct ord{
    //     string kFruit;
    //     uint quantity;
    //     address farmer;
    //     bool send;
    // }

    struct shipment{
        string code;
        address rFarm;
        address rDistri;
        address rMarket;
        uint[2] gfruit;
        uint[2] bfruit;
        uint16 status;
    }

    struct farmer{
        string name;
        string cityState;
        string country;
        uint data; //untuk data
        uint rating; //untuk rating
        uint[] lTrackF;
        bool exist;
    }

    struct distributor{
        string name; 
        string cityState;
        string country;
        uint[] lTrackD;

        bool exist;
    }

    struct market{
        string name;
        string cityState;
        string country;
        uint[] lTrackM;
        bool exist;
    }
    
    constructor() public{
        owner = msg.sender;
    }
    
    //pendaftaran produsen
    function newfarmer(address pub, string name, string cityState, string country) public{
        require(msg.sender == owner);
        farm[pub].name = name;
        farm[pub].cityState = cityState;
        farm[pub].country = country;
        farm[pub].exist = true;
        emit Register(name);
    }
    
    //pendaftaran distributor
    function newdistri(address pub, string name, string cityState, string country) public{
        require(msg.sender == owner);
        distri[pub].name = name;
        distri[pub].cityState = cityState;
        distri[pub].country = country;
        distri[pub].exist = true;
        emit Register(name);
    }

    //pendaftaran market
    function newmarket(address pub, string name, string cityState, string country) public{
        require(msg.sender == owner);
        mark[pub].name = name;
        mark[pub].cityState = cityState;
        mark[pub].country = country;
        mark[pub].exist = true;
        emit Register(name);
    }
  
    //fungsi untuk daftar buah baru
    function newfruit(string code, string _name, string _desc) public{
        require(farm[msg.sender].exist == true);
        goods[code].name = _name;
        goods[code].desc = _desc;
        goods[code].farmer_ = msg.sender;
        goods[code].harv_date = block.timestamp;
    }
    
    //mengirim buah
    function sendFruitFarmer(uint trackid, string code, address next_, uint qty) public{
        ship[trackid].code = code;
        ship[trackid].rDistri = next_;
        ship[trackid].gfruit[0] = qty;
        ship[trackid].bfruit[0] = 0;
        ship[trackid].rFarm = msg.sender;
        ship[trackid].status = 1;
        goods[code].sendDate[0] = block.timestamp;

        farm[msg.sender].lTrackF.push(trackid);
        distri[next_].lTrackD.push(trackid);
    }
    
    function sendFruitDistributor(uint trackid, address next_, uint qty) public{
        ship[trackid].rMarket = next_;
        ship[trackid].gfruit[1] = qty;
        ship[trackid].bfruit[1] = 0;
        mark[next_].lTrackM.push(trackid);

        goods[ship[trackid].code].sendDate[1] = block.timestamp;
    }
    
    //penerimaan
    function recieve_dis(uint trackid) public{
        //require(distri[msg.sender].exist == true);
        require(ship[trackid].rDistri == msg.sender);
        goods[ship[trackid].code].receiveDate[0] = block.timestamp;
        goods[ship[trackid].code].partner[0] = ship[trackid].rDistri;
        goods[ship[trackid].code].status = 0;
        ship[trackid].status = 2;
    }

    function recieve_mar(uint trackid) public{
        //require(mark[msg.sender].exist == true);
        require(ship[trackid].rMarket == msg.sender);
        goods[ship[trackid].code].receiveDate[1] = block.timestamp;
        goods[ship[trackid].code].partner[1] = ship[trackid].rMarket;
        goods[ship[trackid].code].status = 1;
        ship[trackid].status = 3;
    }

    //fitur rating
    function setRating (uint x, address farmer_) public {
        require(farm[farmer_].exist == true);
        require(farmer_ != msg.sender);

        farm[farmer_].rating = farm[farmer_].rating + x;
        farm[farmer_].data = farm[farmer_].data + 1;
	}

    function getRating (address farmer_) public constant returns (uint) {
        return ((farm[farmer_].rating * 10) / farm[farmer_].data);
    }

    //show data buah
    function getFruit(string code) view public returns(string, string,address, uint256, address[2], uint256[2], uint[2]){
        return (goods[code].name, goods[code].desc, goods[code].farmer_,
                goods[code].harv_date, goods[code].partner, goods[code].sendDate, goods[code].receiveDate);
    }

    //show data farmer
    function getFarm(address account) view public returns(string,string,string){
        return (farm[account].name, farm[account].cityState, farm[account].country);
    }
    
    //show distributor
    function getDistri(address account) view public returns(string,string,string){
        return (distri[account].name, distri[account].cityState, distri[account].country);
    }
    
    //update buah
    function updateQuality(uint sCode, uint status, uint qFruit) public {
        ship[sCode].gfruit[status] = ship[sCode].gfruit[status] - qFruit;
        ship[sCode].bfruit[status] = ship[sCode].bfruit[status] + qFruit;
    }

    //show market
    function getMark(address account) view public returns(string,string,string){
        return (mark[account].name, mark[account].cityState, mark[account].country);
    }

    function getShip(uint track) view public returns(string,address, address, address, uint[2], uint[2], uint){
        return (ship[track].code, 
        ship[track].rFarm, 
        ship[track].rDistri, 
        ship[track].rMarket,
        ship[track].gfruit,
        ship[track].bfruit,
        ship[track].status );
    }

    function getTFarm(address account) view public returns (uint[]){
        return farm[account].lTrackF;
    }
    function getTDis(address account) view public returns (uint[]){
        return distri[account].lTrackD;
    }
    function getM(address account) view public returns (uint[]){
        return mark[account].lTrackM;
    }
}