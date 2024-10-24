function showArgs(x, y){
    for(let i = 0; i < arguments.length; i++){
        console.log(arguments[i]);
    }
}
function check(){
    showArgs("Jan", 5);
}


let person = {name : "Jan", age : 5};
console.log(person);
person.age = 6;
person.year = 2000;

person.name = undefined;
delete person.age;

person["name"] = "Jan";

person.name = () => "Jan";





class Person {
    #size = 20; // private field
    constructor(name, age){
        this.name = name;
        this.age = age;
    }
    getFormated(separator){
        return ""+this.name + separator + this.age;
    }
    show(){
        console.log(this.name + " " + this.age);
    }
}

class Animal {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
}

class Dog extends Animal {
    constructor(name, age, breed){
        super(name, age);
        this.breed = breed;
    }
}

let p = new Person("Jan", 5);

let d = new Dog("Burek", 5, "Owczarek");

const tablica = [1, 2, 3, 4, 5];

tablica[-1] = 0;

tablica["name"] = "Jan";

tablica[100] = 100;

tablica[100] = undefined;

tablica[100] = null;


for (let child of tablica) {
    console.log(child);
}