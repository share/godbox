godbox
======

Godbox is a utility for viewing and manipulating data in a LiveDB/ShareJS/Derby.js database.  
For more information on converting a MongoDB database to LiveDB see [Igor](https://github.com/share/igor)

```
npm install
coffee server.coffee
```

# Usage

If you have data in a mongo database called _sweetdb_ and a collection called _stories_ you can navigate to  
[http://localhost:7777/sweetdb/stories](http://localhost:7777/sweetdb/stories)  

to see the items and manipulate them.  

If you are using an alternative redis database (the default is 1) you can set it like
```
coffee server.coffee -r 2
```
where -r selects redis database 2 in this example.
