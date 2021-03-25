---
title: Object Spread、Object.assign
date: 2021-03-25 21:43:07
tags: [前端, es6]
---

# Object Spread、Object.assign

> 笔者在开发的时候,遇到的需求时将多个 Object 整合成一个 Object,不同版本之间,可能存在继承关系,所以只需要从某一个 Object 继承过来,同时修改一些配置文件即可达到快速建版的目的,但是 Object.assign 整合之后,cmd+click 无法主动跳转到配置文件中,所以改换用了 Object Spread 的方式

## Object Spread

object 展开语法,即常见的(...),实际等价与 Object.assign({},obj)

```jsx
const person = { name: "John", age: 24 };
const clonePerson = { ...person };
const workObj = { work: "programer" };

person.name = "July";
person.name; //July
clonePerson === person; //false

const obj = { ...clonePerson, ...workObj };
obj; //{ name: 'John' ,age: 24 ,work: 'programer'}
```

如果是 Object 数据,后者的 key 与前者的 key 相同时,前者会被后者覆盖

即如:

```jsx
const person = { name: "John", age: 24 };
const clonePerson = { ...person, ...{ age: 30 } };
clonePerson; //{ name: 'John' ,age: 30 }
```

## Object.assign

```jsx
const person = { name: "John", age: 24 };
const clonePerson = Object.assign(person, { age: 40 });
person; //{ name: 'John' ,age: 24 },原值person也被修改
clonePerson; //{ name: 'John' ,age: 24 }
```

> 数组类似,不过整合的时候后面的不会和前面的项目发生冲突,所以合并之前是 x 项,y 项,合并之后是 x+y 项

(...) 与 Object.assign 都是深拷贝.但是区别是,Object.assign 的作用是修改第一个参数的值为整合后的 Object ,其他参数项的值不变

---

> 勘误或纠错请联系progerchai@gmail.com,感谢阅读
