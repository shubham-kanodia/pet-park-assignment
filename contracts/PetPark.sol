// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address public owner;
    address public borrower;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Pet {
        AnimalType animalType;
        uint256 count;
    }

    struct BorrowerInfo {
        uint256 age;
        Gender gender;
    }

    //Mapping to assign the borrowed animals to the borrower
    mapping(address => AnimalType) public borrowedAnimals;

    //Mapping to address the borrower info
    mapping(address => BorrowerInfo) public borrowerInfo;

    Pet[] public pets;

    //Events
    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier checkAnimals(AnimalType animalType) {
        require(animalType != AnimalType.None, "Invalid animal");
        _;
    }

    modifier checkAge(uint age) {
        require(age > 0, "Invalid Age");
        _;
    }

    //Initializing the owner and borrower
    constructor() {
        owner = msg.sender;
        borrower = msg.sender;
    }

    function add(
        AnimalType animalType,
        uint256 count
    ) public onlyOwner checkAnimals(animalType) {
        pets.push(Pet(animalType, count));
        emit Added(animalType, count);
    }

    function borrow(
        uint age,
        Gender gender,
        AnimalType animalType
    ) public checkAnimals(animalType) checkAge(age) {
        if (borrowerInfo[msg.sender].age == 0) {
            borrowerInfo[borrower] = BorrowerInfo(age, gender);
        } else {
            require(borrowerInfo[msg.sender].age == age, "Invalid Age");
            require(
                borrowerInfo[msg.sender].gender == gender,
                "Invalid Gender"
            );
        }
        require(
            borrowedAnimals[msg.sender] == AnimalType.None,
            "Already adopted a pet"
        );

        if (gender == Gender.Male) {
            require(
                animalType == AnimalType.Dog || animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        }
        if (gender == Gender.Female) {
            if (age < 40) {
                require(
                    animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }
        borrowerInfo[msg.sender].age = age;
        borrowerInfo[msg.sender].gender = gender;
        for (uint256 i = 0; i < pets.length; i++) {
            if (pets[i].animalType == animalType) {
                require(pets[i].count > 0, "Selected animal not available");
                pets[i].count--;
                borrowedAnimals[msg.sender] = animalType;
            }
        }
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        require(
            borrowedAnimals[msg.sender] != AnimalType.None,
            "No borrowed pets"
        );

        for (uint256 i = 0; i < pets.length; i++) {
            if (pets[i].animalType == borrowedAnimals[msg.sender]) {
                require(pets[i].count > 0, "Selected animal not available");
                pets[i].count++;
            }
        }
        borrowedAnimals[msg.sender] = AnimalType.None;
        emit Returned(borrowedAnimals[msg.sender]);
    }

    function animalCounts(
        AnimalType _animalType
    ) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < pets.length; i++) {
            if (pets[i].animalType == _animalType) {
                count = pets[i].count;
            }
        }
        return count;
    }
}
