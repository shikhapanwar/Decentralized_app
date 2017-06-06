pragma solidity ^0.4.7;
// "class" PhotoShare
contract PhotoShare {
	 
	// data structure of a single photo
	struct Photo {
		//uint timestamp;
		string photoString;
		string topic;
		string geotag;
		address owner;
	}

	struct retArray
	{
		uint numberInArray;
		mapping (uint => string) photoStr;
	}
	retArray val;
	
	// "array" of all photos: maps the photo id to the actual photo
	mapping (uint => Photo) _photos;

	//maps geotag to the photoID
	mapping (string => mapping(uint => uint)) _photoIDFromGeotag;
	mapping (string => uint) _geotagNumPhotos;

	//maps topic to the photoID
	mapping (string => mapping(uint => uint)) _photoIDFromTopic;
	mapping (string => uint) _topicNumPhotos;

	//stores all unique topics
	mapping (uint => string) _listTopicArray;

	//maps photo hash to photoID
	mapping (string => uint) _photoIDFromPhoto;
	
	// total number of photos in the above _photos mapping
	uint public _numberOfPhotos;
	// total number of topics from different pictures
	uint public _numberOfTopics;
	// "owner" : only admin is allowed to photo
	address _adminAddress;
	
	// constructor
	function PhotoShare() {
		_numberOfPhotos = 0;
		_adminAddress = msg.sender;
	}
	
	// returns true if caller of function ("sender") is admin
	function isAdmin() constant returns (bool isAdmin) {
		return msg.sender == _adminAddress;
	}
	
	// add new photo
	function addPhoto(string photoString, string geotag, string topic) returns (int result) {
	
		if (bytes(photoString).length < 0) {
			result = -1;
		} else { 
			_photos[_numberOfPhotos].owner = msg.sender;
			_photos[_numberOfPhotos].photoString = photoString;
			_photos[_numberOfPhotos].geotag = geotag;
			_photos[_numberOfPhotos].topic = topic;

			//update the geotag mapping
			if(_geotagNumPhotos[geotag] ==  0){
				_geotagNumPhotos[geotag] = 1;
				_photoIDFromGeotag[geotag][0] = _numberOfPhotos;
			}
			else{
				_photoIDFromGeotag[geotag][_geotagNumPhotos[geotag]] = _numberOfPhotos;
				_geotagNumPhotos[geotag]++;	
			}

			//update the topic mapping
			if(_topicNumPhotos[topic] == 0){
				_topicNumPhotos[topic] = 1;
				_listTopicArray[_numberOfTopics] = topic;
				_numberOfTopics++;
				_photoIDFromTopic[topic][0] = _numberOfPhotos;
			}
			else{
				_photoIDFromTopic[topic][_geotagNumPhotos[topic]] = _numberOfPhotos;
				_topicNumPhotos[topic]++;
			}
			
			//update the photo to id mapping
			_photoIDFromPhoto[photoString] = _numberOfPhotos;

			_numberOfPhotos++;
			result = 0;
			 // success
		}
	}
	
	function getPhoto(uint photoId) constant returns (string photoString) {
		// returns two values
		photoString = _photos[photoId].photoString;
	}
	
	function countTopic() constant returns (uint) {
		return _numberOfTopics;
	}

	function getTopic(uint ind) constant returns (string) {
		if (ind < _numberOfTopics)
			//return "1";
			return _listTopicArray[ind];
		return "";
	}
	
	function getOwnerAddress() constant returns (address adminAddress) {
		return _adminAddress;
	}
	
	function getNumberOfPhotos() constant returns (uint numberOfPhotos) {
		return _numberOfPhotos;
	}

	//other users can send donations to your account: use this function for donation withdrawal
	function adminRetrieveDonations(address receiver) {
		if (isAdmin()) {
			if(!receiver.send(this.balance)) throw;
		}
	}

	function initialise(){
		val.numberInArray=0;
	}

	function getPhotosFromGeotag(string geotag) constant returns (uint){
		initialise();
		if(_geotagNumPhotos[geotag] >0)
		{
			uint l = 0;
			for(uint i=0;i<_geotagNumPhotos[geotag];i++)
			{
				if(stringsEqual(_photos[_photoIDFromGeotag[geotag][i]].photoString,"0")==false)
				{
					val.photoStr[l]=_photos[_photoIDFromGeotag[geotag][i]].photoString;
					l++;
				}
			}
			val.numberInArray = l;
			return l;
		}
		return 0;	
	}

	function getPhotosFromTopic(string topic) constant returns (uint){
		initialise();
		if(_topicNumPhotos[topic] >0)
		{
			uint l = 0;
			for(uint i=0;i<_topicNumPhotos[topic];i++)
			{
				if(stringsEqual(_photos[_photoIDFromTopic[topic][i]].photoString,"0") == false)
				{	
					val.photoStr[l]=_photos[_photoIDFromTopic[topic][i]].photoString;
					l++;
				}
			}
			val.numberInArray = l;
			return l;
		}
		return 0;	
	}

	function getAllOnStart() constant returns (uint) {
		initialise();
		if (_numberOfPhotos > 0) {
			uint l = 0;
			for (uint i = 0; i < _numberOfPhotos; i++){
				if(stringsEqual(_photos[i].photoString,"0")==false)
				{
					val.photoStr[l] = _photos[i].photoString;
					l++;
				}
			}
			val.numberInArray = l;
			return l;
		}
		return 0;
	}

	function getPhotoInfo(string hash) constant returns(string geotag, string topic, uint owner) {
		uint photoId = _photoIDFromPhoto[hash];
		geotag = _photos[photoId].geotag;
		topic = _photos[photoId].topic;
		if(msg.sender == _photos[photoId].owner)
			owner = 1;
		else
			owner = 0;
	}

	function getAllTopics() constant returns (uint) {
		initialise();
		if (_numberOfPhotos > 0) {
			for (uint i = 0; i < _numberOfPhotos; i++) {
				val.photoStr[i] = _photos[i].topic;
			}
		}
		return val.numberInArray;
	}

	function accessRetArray(uint index) constant returns (string){
		if(index < val.numberInArray)
			return val.photoStr[index];
		return "";
	}

	function stringsEqual(string _a, string _b) constant returns (bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}

	//change
	function deletePicture(string photoHash) returns (bool){
		uint photoId = _photoIDFromPhoto[photoHash];
		Photo _photo = _photos[photoId];
		if (_photo.owner == msg.sender) {
			_photos[photoId].photoString = "0";
			return true;
		}
		//for(uint i=0;i<_numberOfPhotos;i++)
		//{
		//	if(stringsEqual(_photos[i].photoString , photoHash))
		//		_photos[i].photoString = "0";
		//	return true;
		//}
		return false;
	}
	
	
	function adminDelete() {
		if (isAdmin()) {
			suicide(_adminAddress); // this is a predefined function, it deletes the contract and returns all funds to the owner's address
		}
	}

}
