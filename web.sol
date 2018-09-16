pragma solidity ^0.4.18;

/************************************************************************************/
/*       The owned contract is used to set permissions for onlyOwner function       */
/************************************************************************************/
contract owned {
    address public owner;
    function owned () public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

/******************************************/
/*       web contract STARTS HERE       */
/******************************************/
contract web is owned {
    //The price for paying web content
    uint public subscribePrice = 0.001 ether;

    //The company of WEB publisher
    string public registerCompany;

    //The total number of subscription orders
    uint public orderIndex;

    //The revenue of WEB publisher
    uint public subscribeRevenue;

    //The flag that judges if the webPublisher has registered
    bool public doRegister = false;

    //The flag that judges if the webPublisher has released notification
    bool public doNotify = false;

    //The variables of register function
    uint registerId;
    string legalRepresentative;
    string registeredCapital;
    string establishmentDate;
    string operationDeadline;
    uint registerTime;

    //The variables of notify function
    string notifyTitle;
    string notifyContent;
    uint notifyTime;

    //The variables of (free) webcontent function
    string webContentTitle;
    string webContentHash;
    uint webContentPublishedTime;

    //The variables of paidcontent function
    string paidContentTitle;
    string paidContentHash;
    uint paidWebSN;
    uint paidContentPublishedTime;

    //The variables of key (exchange) function
    string keyHash;
    uint keyTime;

    //The variables of withdraw function
    uint withdrawTime;

    //This creates arrays for paidcontent order information
    mapping (uint => address) public orderIdSubscriber;
    mapping (address => mapping(uint => Order)) public indent;

    //The Order struct for paidcontent subscription
    struct Order {
        uint orderId;

        //The issue of paidcontent
        uint webSN;

        //the pubkey of paying WEB user
        string pubkeyHash;

        //The Amount is 0.001 ether here
        uint paymentAmount;

        address subscribeAddress;
        address receipientAddress;
        string webPublisher;
        address publisherAddress;
        uint subscribeTime;

        //The flag that judges if the WEB user has paid for the orders
        bool isPaid;
    }

    //The events for each web function
    event newRegister(string registerCompany, uint registerId, string legalRepresentative, string registeredCapital, string establishmentDate, string operationDeadline, address registerAddress, uint registerTime);
    event newNotify(string notifyTitle, string notifyContent, string webPublisher, uint notifyTime);
    event newWebContent(string webContentTitle, string webContentHash, string webPublisher, address publisherAddress, uint webContentPublishedTime);
    event newPaidContent(string paidContentTitle, string paidContentHash, string webPublisher, address publisherAddress, uint WebSN, uint paidContentPublishedTime);
    event newSubscribe(uint orderId, uint webSN, uint paymentAmount, address subscribeAddress, address receipientAddress, string webPublisher, address publisherAddress, string pubkeyHash, uint subscribeTime);
    event newKey(uint orderId, uint webSN, string keyHash, address subscribeAddress, string webPublisher, address publisherAddress, uint keyTime);
    event newWithdraw(string withdrawCompany, address withdrawAddress, uint withdrawMount, uint withdrawTime);

    //The WEB publisher registers company
    function register(string _registerCompany, uint _registerId, string _legalRepresentative, string _registeredCapital, string _establishmentDate, string _operationDeadline) onlyOwner public {
        registerCompany = _registerCompany;
        registerId = _registerId;
        legalRepresentative = _legalRepresentative;
        registeredCapital = _registeredCapital;
        establishmentDate = _establishmentDate;
        operationDeadline = _operationDeadline;
        registerTime = now + 0 seconds;
        doRegister = true;
        emit newRegister(registerCompany, registerId, legalRepresentative, registeredCapital, establishmentDate, operationDeadline, owner, registerTime);
    }

    //The WEB publisher releases notification
    function notify(string _notifyTitle, string _notifyContent) onlyOwner public {
        require(doRegister);
        notifyTitle = _notifyTitle;
        notifyContent = _notifyContent;
        notifyTime = now + 0 seconds;
        doNotify = true;
        emit newNotify(notifyTitle, notifyContent, registerCompany, notifyTime);
    }

    //The WEB publisher releases (free) webcontent
    function webcontent(string _webContentTitle, string _webContentHash) onlyOwner public {
        require(doNotify);
        webContentTitle = _webContentTitle;
        webContentHash = _webContentHash;
        webContentPublishedTime = now + 0 seconds;
        emit newWebContent(webContentTitle, webContentHash, registerCompany, owner, webContentPublishedTime);
    }

    //The WEB publisher releases paidcontent
    function paidcontent(string _paidContentTitle, string _paidContentHash, uint _WebSN) onlyOwner public {
        require(doNotify);
        paidContentTitle = _paidContentTitle;
        paidContentHash = _paidContentHash;
        paidWebSN = _WebSN;
        paidContentPublishedTime = now + 0 seconds;
        emit newPaidContent(paidContentTitle, paidContentHash, registerCompany, owner, paidWebSN, paidContentPublishedTime);
    }

    //The WEB user subscribes paidcontent
    function subscribe(uint _webSN, string _pubkeyHash) payable public {
        require(doNotify);
        require(msg.value == subscribePrice);
        orderIndex += 1;
        Order memory order = Order(orderIndex, _webSN, _pubkeyHash, msg.value, msg.sender, this, registerCompany, owner, now + 0 seconds, true);
        indent[msg.sender][orderIndex] = order;
        orderIdSubscriber[orderIndex] = msg.sender;
        subscribeRevenue += msg.value;
        emit newSubscribe(order.orderId, order.webSN, order.paymentAmount, order.subscribeAddress, order.receipientAddress, order.webPublisher, order.publisherAddress, order.pubkeyHash, order.subscribeTime);
    }

    //The WEB publisher exchanges key
    function key(uint _orderId, string _keyHash) onlyOwner public {
        Order storage order = indent[orderIdSubscriber[_orderId]][_orderId];
        require(order.isPaid == true);
        keyHash = _keyHash;
        keyTime = now + 0 seconds;
        emit newKey(order.orderId, order.webSN, keyHash, order.subscribeAddress, order.webPublisher, order.publisherAddress, keyTime);
    }

    //The WEB Publisher withdraws money(ethers)
    function withdraw() public onlyOwner {
        owner.transfer(subscribeRevenue);
        withdrawTime = now + 0 seconds;
        emit newWithdraw(registerCompany, msg.sender, subscribeRevenue, withdrawTime);
    }

}
