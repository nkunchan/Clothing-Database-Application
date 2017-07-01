var knex = require('knex')({
    client: 'mysql',
    connection: {
        host     : 'localhost',
        user     : 'root',
        password : '',
        database : 'Catawba',
        charset  : 'utf8'
  }
});

var express = require("express");
var Bookshelf = require('bookshelf')(knex);
var bodyParser = require('body-parser');
var http    = require('http');
var formidable = require('formidable');
var uuid = require('uuid');
var aws = require('aws-sdk');
var path = require('path');

var app = express();

var server = http.createServer(app);

app.use(require('morgan')('dev'));

var session = require('express-session');

var FileStore = require('session-file-store')(session);

var nodemailer = require('nodemailer');

app.use(session({
    name: 'server-session-cookie-id',
    secret: 'catawba secret',
    saveUninitialized: true,
    resave: true,
    store: new FileStore()
}));

var router = express.Router();


app.use(express.static(__dirname))

var JWTKEY = 'CatawbaDatabase'; // Key for Json Web Token

// body-parser middleware for handling request variables
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.set('view engine', 'ejs');

var ApprovedItem = Bookshelf.Model.extend({
    tableName: 'approveditems'
});

var DonorRequest = Bookshelf.Model.extend({
    tableName: 'donorrequests'
});

var CartItem = Bookshelf.Model.extend({
    tableName: 'cartitem'
});

var Items = Bookshelf.Model.extend({
    tableName: 'items'
});

var Category = Bookshelf.Model.extend({
  tableName: 'categories'
});

var User = Bookshelf.Model.extend({
    tableName: 'applicationuser'
});

var CategoryItem = Bookshelf.Model.extend({
  tableName: 'itemCategory',
    category: function() {
        return this.belongsTo(Category, "CategoryId");
    },
    approveditem: function() {
        return this.belongsTo(ApprovedItem, "ItemId");
    }
});

var UncheckedItems = Bookshelf.Model.extend({
   tableName: 'uncheckeditems'
});

var Cart = Bookshelf.Model.extend({
    tableName: 'cart'
});

app.post('/revokeAccess', function (req, res) {
    var Role = '';
    if(req.session.user.Role == 'Member') {
        Role = 'User';
    } else if(req.session.user.Role == 'Admin'){
        Role = req.body.role;
    }
    knex('applicationuser')
        .where('UserId', req.body.userId)
        .update({
            Role: Role
        })
        .then(function (user) {
            knex('applicationuser')
                .whereNot('UserId', req.session.user.UserId)
                .then(function (users) {
                    res.render('pages/users',{error: false,
                        alert: false,
                        users: users,
                        categories: req.session.categories,
                        categorySelected: req.session.selectedCategoryId,
                        loggedIn: req.session.loggedIn,
                        user: req.session.user});
                })
                .catch(function (err) {
                    res.render('pages/users', {error: true,
                        message: err.message,
                        users: [],
                        categories: req.session.categories,
                        categorySelected: req.session.selectedCategoryId,
                        loggedIn: req.session.loggedIn,
                        user: req.session.user});
                });
        })
        .catch(function (err) {
            res.render('pages/users', {error: true,
                message: err.message,
                users: [],
                categories: req.session.categories,
                categorySelected: req.session.selectedCategoryId,
                loggedIn: req.session.loggedIn,
                user: req.session.user});
        });
});

app.post('/makeDonor', function (req, res) {
   knex
       .raw('call makeDonor(?)', req.body.userId)
       .then( function (response) {
           knex('applicationuser')
               .whereNot('UserId', req.session.user.UserId)
               .then(function (users) {
                   res.render('pages/users',{error: false,
                       alert: false,
                       users: users,
                       categories: req.session.categories,
                       categorySelected: req.session.selectedCategoryId,
                       loggedIn: req.session.loggedIn,
                       user: req.session.user});
               })
               .catch(function (err) {
                   res.render('pages/users', {error: true,
                       message: err.message,
                       users: [],
                       categories: req.session.categories,
                       categorySelected: req.session.selectedCategoryId,
                       loggedIn: req.session.loggedIn,
                       user: req.session.user});
               });
       })
       .catch(function (err) {
           res.render('pages/users', {error: true,
               message: err.message,
               users: [],
               categories: req.session.categories,
               categorySelected: req.session.selectedCategoryId,
               loggedIn: req.session.loggedIn,
               user: req.session.user});
       });
});

app.get('/', function(req, res) {
    //var decoded = jwt.verify(req.body.token, JWTKEY);
      //if(decoded) {
        knex.from('categories')
          .then(function (categoriesCollection) {
              req.session.categories = categoriesCollection;
              if(!req.session.loggedIn) {
                  req.session.loggedIn = false;
              }
              knex.from('items')
                  .where('IsApproved', 1)
                .then(function (itemsCollection) {
                    req.session.items = itemsCollection;
                    res.render('pages/index', {error: false, items: itemsCollection, categories: categoriesCollection, categorySelected: 'None', loggedIn: req.session.loggedIn, alert: false, user: req.session.user});
                })
                .catch(function (err) {
                    res.render('pages/index', {error: true, message: err.message});
              });
          })
          .catch(function (err) {
              res.status(500).json({error: true, message: err.message});
          });
        
        //  }else {
          //  res.json({error: true, data: {message: 'invalid token'}});
          //}
});

app.post('/login', function (req, res) {
    var email = req.body.email;
    var password = req.body.password;
    User.forge({EmailId: email, Password: password})
        .fetch()
        .then(function (user) {
            if (!user) {
                res.render('pages/index', {error: true, message: "Invalid user credentials", items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId});
            } else {
                req.session.user = user.attributes;
                req.session.userId = user.attributes.UserId;
                req.session.loggedIn = true;
                res.render('pages/index', {error: false, alert: false, items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
            }
        })
        .catch(function (err) {
            res.render('pages/index', {error: true, message: err.message, items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId});
        });
});

app.post('/donate', function (req, res) {
    var form = new formidable.IncomingForm();
    form.parse(req, function(err, fields, files) {// `file` is the name of the <input> field of type `file`
        // aws.config.update({
        //     accessKeyId: 'KEY',
        //     secretAccessKey: 'SECRET'
        // });
        //
        // var s3 = new aws.S3();
        //
        // var params = {
        //     Bucket: 'catawba',
        //     Key: fields.itemName,
        //     ACL: 'public-read-write',
        //     ContentType: 'image/jpeg',
        //     Body: files.image.path
        // };
        //
        // s3.putObject(params, function (perr, pres) {
        //     if (perr) {
        //         console.log("Error uploading data: ", perr);
        //     } else {
        //         console.log("Successfully uploaded data to myBucket/myKey"+JSON.stringify(pres));
        //     }
        // });

            var url = '/images/'+fields.itemName+'.jpg';
                knex.raw('call donateItem(?,?,?,?,?,?,?)', [uuid.v1(), fields.itemName, fields.description, fields.price, fields.quantity, req.session.user.UserId, url])
                    .then(function (user) {
                        var message = 'Thank you for donating '+req.body.itemName+'! The item will be available once the moderators approve it. You will receive the donation receipt shortly.';
                        res.render('pages/index', {error: false, alert: true, message: message, categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                    })
                    .catch(function (err) {
                        var message = 'Oops! Something went wrong. Please try again later.';
                        console.log(err.message);
                        res.render('pages/index', {error: true, alert: false, message: message, categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                    })

            },
            function(errMsg, errObject){ //error
                console.error('unable to upload: ' + errMsg + ':', errObject);
                // execute error code
            });
    //});
});

app.get('/getNewItems', function (req, res) {
   knex('items')
       .where('IsApproved', 0)
       .then( function (newItems) {
           res.render('pages/index', {error: false, alert: false, new: true, categories: req.session.categories, items: newItems, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
       })
       .catch( function (err) {
           res.render('pages/index', {error: true, alert: false, message: err.message, categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
       });
});

app.post('/updateItem', function (req, res) {
    knex.raw('call approveItem(?,?,?,?,?,?,?)',[req.body.itemName, req.body.price, req.body.quantity, req.body.description, req.body.itemId, req.body.categorySelectId, req.session.user.UserId])
            .then(function (count) {
                    knex('items').innerJoin('approvedItems', 'items.ItemId', 'approvedItems.ItemId')
                        .then(function (refreshItems) {
                            var totalPrice = req.body.price * req.body.quantity;
                            var transporter = nodemailer.createTransport({
                                service: 'Gmail',
                                auth: {
                                    user: 'catawbaapplication@gmail.com', // Your email id
                                    pass: 'Catawba@123' // Your password
                                }
                            });
                            var mailOptions = {
                                from: 'catawbaapplication@gmail.com', // sender address
                                to: 'mounicachirva@gmail.com', // list of receivers
                                subject: 'Donation Receipt', // Subject line
                                //text: text //, // plaintext body
                                html: '<b>This is a receipt for your donation to Catawba for a value of '+totalPrice+'✔ </b>' // You can choose to send an HTML body instead
                            };
                            transporter.sendMail(mailOptions, function(error, info){
                                if(error){
                                    console.log(error);
                                }else{
                                    console.log('Message sent: ' + info.response);
                                };
                            });
                            res.render('pages/index', {error: false, alert: false, items: refreshItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                        })
                        .catch(function (err) {
                            res.render('pages/index', {error: true, message: err.message, alert: false, items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                        });
                })
                .catch(function (err) {
                    res.render('pages/index', {error: true, message: err.message, items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, user: req.session.user});
                });
});

app.get('/getMyAccount', function (req, res) {
    if(req.session.user != null) {
        if(req.session.user.Address) {
            res.render('pages/account', {
                error: false,
                alert: false,
                categories: req.session.categories,
                loggedIn: req.session.loggedIn,
                categorySelected: req.session.selectedCategoryId,
                address: req.session.user.Address.split(','),
                user: req.session.user
            });
        } else {
            console.log('Maybe'-req.session.user);
            res.render('pages/account', {
                error: false,
                alert: false,
                categories: req.session.categories,
                loggedIn: req.session.loggedIn,
                address: '',
                categorySelected: req.session.selectedCategoryId,
                user: req.session.user
            });
        }
    } else {
        console.log('here?');
        res.render('pages/account', {error: true, alert: false, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, message: err.message});
    }
});

app.post('/updateProfile', function (req, res) {
    var newsletter = (req.body.newsletter == "on") ? 1 : 0;
    var address = req.body.lineone + ','+req.body.linetwo+','+req.body.city+','+req.body.state+','+req.body.postcode+','+req.body.country+','+req.body.country;
    var update = {};
    if(req.body.password == '') {
        update = {
            Name: req.body.name,
            EmailId: req.body.email,
            IsSubscribed: newsletter,
            Address: address,
            Phone: req.body.phone
        };
    } else if (req.body.password == req.body.repassword) {
        update = {
            Name: req.body.name,
            EmailId: req.body.email,
            IsSubscribed: newsletter,
            Password: req.body.password,
            Address: address,
            Phone: req.body.phone
        };
    }

    knex('applicationuser')
        .where('UserId', req.session.user.UserId)
        .update(update)
        .then(function (user) {
            req.session.user.Name = req.body.name;
            req.session.user.EmailId = req.body.email;
            req.session.user.IsSubscribed = newsletter;
            req.session.user.Address = address;
            if(!req.body.password == '') {
                req.session.user.Password = req.body.password;
            }
            res.render('pages/index', {error: false, alert: true, items: req.session.items, message: 'Profile Updated', categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, user: req.session.user});
        })
        .catch( function (err) {
            res.render('pages/index', {error: true, alert: false, items: req.session.items, message: err.message+' Something went wrong! Please try again later', categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, user: req.session.user});
        });

});

app.post('/saveItem', function (req, res) {
    knex.from('items')
        .where('ItemId', req.body.itemId)
        .update({
            ItemName: req.body.itemName,
            Price: req.body.price,
            Quantity: req.body.quantity,
            Description: req.body.description,
            IsApproved: 1
        })
        .then(function (item) {
            knex('items').innerJoin('approvedItems', 'items.ItemId', 'approvedItems.ItemId')
                .then(function (refreshItems) {
                    res.render('pages/index', {error: false, alert: true, message: 'Item updated!', items: refreshItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                })
                .catch(function (err) {
                    res.render('pages/index', {error: true, message: err.message, alert: false, items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                });
        })
        .catch( function (err) {
            res.render('pages/index', {error: true, message: err.message, alert: false, items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
        });
});


app.post('/uncheckItem', function (req, res) {
    knex('items')
        .where('ItemId', req.body.itemId)
        .update({IsApproved: -1})
        .then( function (items) {
            res.redirect('/getNewItems');
        })
        .catch( function (err) {
            res.render('pages/index', {error: true, alert: false, message: message, items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, user: req.session.user});
        });
});

app.post('/register', function (req, res) {
    var userId = uuid.v1();
    var name = req.body.name;
    var email = req.body.email;
    var password = req.body.password;
    var repassword = req.body.repassword;
    var newsletter = (req.body.newsletter == "on") ? 1 : 0;
    if (password == repassword) {
        User.forge({
            UserId: userId,
            Name: name,
            EmailId: email,
            Password: password,
            IsSubscribed: newsletter,
            Role: 'User'
        })
            .save(null, {method: 'insert'})
            .then(function (user) {
                req.session.loggedIn = true;
                req.session.user = user.attributes;
                req.session.userId = user.attributes.UserId;
                Cart.forge({
                    CartId: uuid.v1(),
                    UserId: req.session.userId
                })
                .save(null, {method: 'insert'})
                .then(function (cart) {
                    req.session.cartId = cart.attributes.CartId;
                    res.render('pages/index', {error: false, alert: false, items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
                })
                .catch(function (err) {
                    res.render('pages/index', {error: true, message: err.message, items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId, user: req.session.user});
                });
            })
            .catch(function (err) {
                console.log(err.message);
                if (err.code == 'ER_DUP_ENTRY') {
                    res.render('pages/index', {error: true, alert: false, message: 'Email Address already exists! Try logging in.', items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId});
                }
                else{
                    res.render('pages/index', {error: true, message: err.message, items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId});
                }
            });
    }
    else{
        res.render('pages/index', {error: true, message: 'Passwords do not match! Please try again.', items: req.session.items, categories: req.session.categories, loggedIn: req.session.loggedIn, categorySelected: req.session.selectedCategoryId});
    }
});

app.get('/confirmCheckout', function (req, res) {
    if(req.session.loggedIn) {
        if(req.session.user.Address == null) {
            res.render('pages/address', {error: false, alert: false, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, address: '', user: req.session.user});
        }
        else {
            res.render('pages/address', {error: false, alert: false, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, address: req.session.user.Address.split(','), user: req.session.user});
        }
    }
    else {
        res.render('pages/address', {error: false, alert: false, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, address: ''});
    }
});

app.post('/checkout', function (req, res) {
    if(req.session.loggedIn) {
        knex
            .raw('call checkOut(?)', req.session.userId)
            .then( function (response) {
                knex('solditem').innerJoin('items', 'solditem.ItemId', 'items.ItemId')
                    .where('solditem.Buyer', req.session.userId)
                    .then( function (solditems) {
                        res.render('pages/orders', {error: false, alert: true, message: 'Order has been placed!', loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, user: req.session.user, solditems: solditems});
                    })
                    .catch( function (err) {
                        res.render('pages/orders', {error: true, alert: false, message: err.message, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, user: req.session.user, solditems: []});
                    });
            })
            .catch( function (err) {
                console.log(err);
            });
    }
    else {
        knex
            .raw('call guestCheckOut(?)', req.session.cartid)
            .then(function (response) {
                if(req.session.cartitems) {
                    req.session.cartitems = [];
                }
                res.render('pages/index', {
                    error: false,
                    alert: true,
                    message: 'Order placed!',
                    loggedIn: req.session.loggedIn,
                    categories: req.session.categories,
                    categorySelected: req.session.selectedCategoryId,
                    items: req.session.items
                });
            })
            .catch(function (err) {
                res.render('pages/index', {
                    error: true,
                    message: err.message,
                    loggedIn: req.session.loggedIn,
                    categories: req.session.categories,
                    categorySelected: req.session.selectedCategoryId,
                    items: req.session.items
                });
            });
    }
});

app.get('/getMyOrders', function (req, res) {
    knex('solditem').innerJoin('items', 'solditem.ItemId', 'items.ItemId')
        .where('solditem.Buyer', req.session.userId)
        .then( function (solditems) {
            res.render('pages/orders', {error: false, alert: false, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, user: req.session.user, solditems: solditems});
        })
        .catch( function (err) {
            res.render('pages/orders', {error: true, alert: false, message: err.message, loggedIn: req.session.loggedIn, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, user: req.session.user, solditems: []});
        });
});

app.post('/getCategory', function(req, res) {
    //  var decoded = jwt.verify(req.body.token, JWTKEY);
    //   if(decoded) {
        req.session.selectedCategoryId = req.body.categorySelectId;
        if(req.session.selectedCategoryId == 'all') {
          if(req.body.searchTerm == '') {
            knex.from('items').innerJoin('itemcategory', 'items.ItemId', 'itemcategory.ItemId')
              .then(function(categoryItems) {
                  req.session.items = categoryItems;
                  res.render('pages/index', {error: false, alert: false, items: categoryItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
              })
              .catch(function (err){
                  res.status(500).json({error: true, message: err.message});
            })
          }
          else {
            knex.from('items').innerJoin('itemcategory', 'items.ItemId', 'itemcategory.ItemId')
              .where('ItemName', 'LIKE', '%'+req.body.searchTerm+'%')
              .then(function(categoryItems) {
                  req.session.items = categoryItems;
                  res.render('pages/index', {error: false, alert: false, items: categoryItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
              })
              .catch(function (err){
                  res.status(500).json({error: true, message: err.message});
            })
          }
        }
        else {
          if(req.body.searchTerm == '') {
            knex.from('items').innerJoin('itemcategory', 'items.ItemId', 'itemcategory.ItemId')
              .where('CategoryId',req.session.selectedCategoryId)
              .then(function(categoryItems) {
                  req.session.items = categoryItems;
                  res.render('pages/index', {error: false, alert: false, items: categoryItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});

              })
              .catch(function (err){
                  res.status(500).json({error: true, message: err.message});
            })
          }
          else {
            knex.from('items').innerJoin('itemcategory', 'items.ItemId', 'itemcategory.ItemId')
              .where('CategoryId',req.session.selectedCategoryId)
              .andWhere('ItemName', 'LIKE', '%'+req.body.searchTerm+'%')
              .then(function(categoryItems) {
                  req.session.items = categoryItems;
                  res.render('pages/index', {error: false, alert: false, items: categoryItems, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
              })
              .catch(function (err){
                  res.render('pages/index', {error: true, message: err.message, user: req.session.user});
            })
          }
        }

      // }else {
      //   res.json({error: true, data: {message: 'invalid token'}});
      // }
    
});

app.post('/requestToDonate', function (req, res) {
    DonorRequest.forge({
        RequesterId: req.session.user.UserId,
        UpdateDateTime: new Date()
    })
        .save(null, {method: 'insert'})
        .then(function (user) {
           res.render('pages/index', {error: false, alert: true, message: 'Request placed!', categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
        })
        .catch( function (err) {
            if (err.code == 'ER_DUP_ENTRY') {
                res.render('pages/index', {error: true, alert: false, message: 'Request already placed!', categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
            }
            else {
                res.render('pages/index', {error: true, alert: false, message: err.message, categories: req.session.categories, items: req.session.items, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
            }

        });
});

app.post('/getCart', function (req, res){
    if(!req.session.loggedIn) {
        if(!req.session.cartitems || req.session.cartitems.length == 0) {
            res.render('pages/cart', {error: false, alert: false, cartitems: [], items: req.session.items, categories: req.session.categories, categorySelected: req.session.selectedCategoryId, loggedIn: req.session.loggedIn, user: req.session.user});
        }
        else {
            var itemIds = [];
            for (var j = 0; j < req.session.cartitems.length; j++) {
                itemIds.push(req.session.cartitems[j].item);
            }
            knex.select('ItemId', 'Quantity as totalQuantity', 'ItemName', 'Description', 'Price', 'Discount', 'OnSale', 'ImageUrl').from('items')
                .whereIn('ItemId', itemIds)
                .then(function (items) {
                    var approveditems =[];
                    for (var index = 0; index < items.length; index++) {
                        items[index].Quantity = req.session.cartitems[index]['quantity'];
                        approveditems.push(items[index]);
                        if(index == req.session.cartitems.length - 1) {
                            res.render('pages/cart', {
                                error: false,
                                alert: false,
                                cartitems: approveditems,
                                items: req.session.items,
                                categories: req.session.categories,
                                categorySelected: req.session.selectedCategoryId,
                                loggedIn: req.session.loggedIn
                            });
                        }
                    }
                })
                .catch(function (err) {
                    res.render('pages/cart', {
                        error: true,
                        message: err.message,
                        cartitems: [],
                        items: req.session.items,
                        categories: req.session.categories,
                        categorySelected: req.session.selectedCategoryId,
                        loggedIn: req.session.loggedIn
                    });
                });
            }
        } else {
            knex.select('cartItem.ItemId', 'cartitem.Quantity', 'items.Quantity as totalQuantity', 'items.ItemName', 'items.Description', 'items.Price', 'items.Discount', 'items.OnSale', 'items.ImageUrl').from('cartitem').innerJoin('cart', 'cartitem.CartId', 'cart.CartId').innerJoin('items', 'cartitem.ItemId', 'items.ItemId')
                .where('cart.UserId', req.session.userId)
                .then(function (cartitems) {
                    console.log(cartitems);
                    res.render('pages/cart', {
                        error: false,
                        alert: false,
                        cartitems: cartitems,
                        categories: req.session.categories,
                        categorySelected: req.session.selectedCategoryId,
                        loggedIn: req.session.loggedIn,
                        user: req.session.user
                    });
                })
                .catch(function (err) {
                    console.log(err);
                    res.render('pages/cart', {
                        error: true,
                        message: err.message,
                        caritems: [],
                        totalPrice: 0,
                        items: req.session.items,
                        categories: req.session.categories,
                        categorySelected: req.session.selectedCategoryId,
                        loggedIn: req.session.loggedIn,
                        user: req.session.user
                    });
                });
        }
});

app.get('/getUsers', function (req, res) {
    knex('applicationuser').leftJoin('donorrequests', 'applicationuser.UserId', 'donorrequests.RequesterId')
        .whereNot('applicationuser.UserId', req.session.user.UserId)
        .then(function (users) {
            res.render('pages/users', {error: false,
                alert: false,
                users: users,
                categories: req.session.categories,
                categorySelected: req.session.selectedCategoryId,
                loggedIn: req.session.loggedIn,
                user: req.session.user})
        })
        .catch( function (err) {
            res.render('pages/users', {error: true,
                message: err.message,
                users: [],
                categories: req.session.categories,
                categorySelected: req.session.selectedCategoryId,
                loggedIn: req.session.loggedIn,
                user: req.session.user})
        });
});

app.post('/deleteItem', function (req, res) {
   if(req.session.loggedIn) {
       knex.from('cart')
           .where('UserId', req.session.userId)
           .then( function (cart) {
               knex.from('cartitem')
                   .where('CartId', cart[0].CartId)
                   .andWhere('ItemId', req.body.itemId)
                   .del()
                   .then( function (count) {
                       res.redirect(307, '/getCart');
                   })
                   .catch( function (err) {
                       res.render('pages/cart', {
                           error: true,
                           message: err.message,
                           cartitems: [],
                           items: req.session.items,
                           categories: req.session.categories,
                           categorySelected: req.session.selectedCategoryId,
                           loggedIn: req.session.loggedIn,
                           user: req.session.user
                       });
                   })
           })
           .catch(function (err) {
               res.render('pages/cart', {
                   error: true,
                   message: err.message,
                   cartitems: [],
                   items: req.session.items,
                   categories: req.session.categories,
                   categorySelected: req.session.selectedCategoryId,
                   loggedIn: req.session.loggedIn,
                   user: req.session.user
               });
           });
   }
   else {
       knex('cartitem')
           .where('CartId', req.session.cartid)
           .andWhere('ItemId', req.body.itemId)
           .del()
           .then(function (success) {
               var index = -1;
               for (var i = 0; i < req.session.cartitems.length; i++) {
                   console.log(i);
                   if (req.session.cartitems[i] == req.body.itemId) {
                       index = i;
                   }
               }
               req.session.cartitems.splice(index, 1);
               console.log(req.session.cartitems);
               res.redirect(307, '/getCart');
           })
           .catch(function (err) {
               console.log(err);
           });
   }
});

app.post('/saveCart', function(req, res) {
    if(req.session.loggedIn) {
        console.log(req.session.userId+" "+req.body.itemId + " "+req.body.itemQuantity);
        knex.from('cartitem').innerJoin('cart', 'cart.CartId', 'cartitem.CartId')
            .where('cart.UserId', req.session.userId)
            .andWhere('cartitem.ItemId', req.body.itemId)
            .update({Quantity: req.body.itemQuantity})
            .then(function (cartItem) {
                res.redirect(307, '/getCart');
            })
            .catch(function (err) {
                res.render('pages/cart', {
                    error: true,
                    message: err.message,
                    cartitems: [],
                    items: req.session.items,
                    categories: req.session.categories,
                    categorySelected: req.session.selectedCategoryId,
                    loggedIn: req.session.loggedIn,
                    user: req.session.user
                });
            })
    }
    else  {
        knex('cartitem')
            .where('CartId', req.session.cartid)
            .andWhere('ItemId', req.body.itemId)
            .update({Quantity: req.body.itemQuantity})
            .then( function (success) {
                for(var i = 0; i < req.session.cartitems.length; i++) {
                    if (req.session.cartitems[i].item == req.body.itemId) {
                        req.session.cartitems[i].quantity = req.body.itemQuantity;
                        res.redirect(307, '/getCart');
                    }
                }
            })
            .catch( function (err) {
                console.log(err);
            });
    }
});

app.post('/addToCart', function(req,res){
    if (req.session.loggedIn) {
        knex('cartitem').innerJoin('cart', 'cart.CartId', 'cartItem.CartId')
            .where('cart.UserId', req.session.userId)
            .where('cartItem.ItemId', req.body.itemId)
            .then(function (items) {
                if(items.length > 0) {
                    var Cartid = items[0].CartId;
                    knex('items')
                        .where('ItemId', req.body.itemId)
                        .then( function (appItems) {
                            console.log(items[0].Quantity+" "+appItems[0].Quantity);
                            if (items[0].Quantity < appItems[0].Quantity) {
                                knex('cartitem')
                                    .where('ItemId', req.body.itemId)
                                    .andWhere('CartId', Cartid)
                                    .increment('Quantity', 1)
                                    .then(function (cartitem) {
                                        res.redirect(307, '/getCart');
                                    })
                                    .catch( function (err) {
                                        res.redirect(307, '/getCart');
                                    })
                            }
                            else {
                                res.redirect(307, '/getCart');
                            }
                        })
                }
                else{
                    knex('cart')
                        .where('UserId', req.session.userId)
                        .then( function (cart) {
                            CartItem.forge({
                                CartId: cart[0].CartId,
                                ItemId: req.body.itemId,
                                Quantity: 1
                            })
                                .save(null, {method: 'insert'})
                                .then(function (cartitem) {
                                    res.redirect(307, '/getCart');
                                })
                                .catch(function (err) {
                                    res.redirect(307, '/getCart');
                                });
                        })
                }
            })
            .catch( function (err) {

            });
    }
    else {
        req.session.cartid = uuid.v1();
        knex.raw('call guestAddToCart(?,?)', [req.session.cartid, req.body.itemId])
            .then(function (success) {
                if (!req.session.cartitems) {
                    req.session.cartitems = [];
                    knex.from('items')
                        .where('ItemId', req.body.itemId)
                        .then(function (items) {
                            req.session.cartitems.push({
                                item: req.body.itemId,
                                quantity: 1,
                                totalQuantity: items[0].Quantity
                            });
                            res.redirect(307, '/getCart');
                        })
                        .catch(function (err) {
                            console.log(err);
                            res.redirect(307, '/getCart');
                        });
                }
                else {
                    var existing = 0;
                    var index = -1;
                    for (var i = 0; i < req.session.cartitems.length; i++) {
                        if (req.session.cartitems[i].item == req.body.itemId) {
                            existing = 1;
                            index = i;
                            console.log('existing');
                        }
                    }
                    if (existing == 0) {
                        req.session.cartitems.push({item: req.body.itemId, quantity: 1});
                        res.redirect(307, '/getCart');
                    }
                    else {
                        knex.from('items')
                            .where('ItemId', req.body.itemId)
                            .then(function (items) {
                                if (items[0].Quantity > req.session.cartitems[index].quantity) {
                                    req.session.cartitems[index].quantity = req.session.cartitems[index].quantity + 1;
                                    console.log(req.session.cartitems[index]);
                                    res.redirect(307, '/getCart');
                                }
                                else {
                                    res.redirect(307, '/getCart');
                                }
                            })
                            .catch(function (err) {
                                console.log(err);
                            });
                    }
                }
            })
            .catch(function (err) {
                console.log(err);
                res.redirect(307, '/getCart');
            });
    }
});

app.post('/getItem', function (req, res) {
    knex('items')
        .where('ItemId', req.body.itemId)
        .then( function (items) {
           res.render('pages/editItem', {error: false, alert: false, categories: req.session.categories, item: items[0], loggedIn: req.session.loggedIn, user: req.session.user, categorySelected: req.session.selectedCategoryId});
        })
        .catch( function (err) {
            res.render('pages/editItem', {error: true, message: err.message, alert: false, categories: req.session.categories, item: {}, loggedIn: req.session.loggedIn, user: req.session.user});
        });
});

app.get('/logout', function (req, res){
    req.session.destroy();
    res.redirect('/');
});


app.listen(3000,function(){
  console.log("Live at Port 3000");
});