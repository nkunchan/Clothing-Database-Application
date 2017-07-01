var Schema = {
  items: {
    ItemId:{type: 'string', maxlength: 254, nullable: false, primary: true},
    ItemName: {type: 'string', maxlength: 50, nullable: false},
    Description: {type: 'string', maxlength: 500, nullable: false},
    Price: {type: 'decimal', nullable: false},
    OnSale: {type: 'boolean', nullable: false},
    Discount: {type: 'decimal', nullable: true},
    Quantity: {type: 'integer', nullable: false},
    IsApproved: {type: 'integer', nullable: false},
    ImageUrl: {type: 'string', maxlength: 500, nullable: false}
  },
  approveditems: {
    ItemId: {type: 'string', maxlength: 254, nullable: false},
    ApprovedBy: {type: 'string', maxlength: 254, nullable: false}
  },
  uncheckedItems: {
    ItemId: {type: 'string', maxlength: 254, nullable: false},
    UncheckedBy: {type: 'string', maxlength: 254, nullable: false}
  },
  categories: {
    CategoryId: {type: 'string', maxlength: 254, nullable: false, primary: true},
    CategoryName: {type: 'string', maxlength: 50, nullable: false}
  },
  itemcategory: {
    CategoryId: {type: 'string', maxlength: 254, nullable: false},
    ItemId: {type: 'string', maxlength: 254, nullable: false}
  },
  applicationuser: {
    UserId: {type: 'string', maxlength: 254, nullable: false, primary: true},
    Name: {type: 'string', maxlength: 50, nullable: false},
    EmailId: {type: 'string', maxlength: 100, nullable: false},
    Password: {type: 'string', maxlength: 500, nullable: false},
    Address: {type: 'string', maxlength: 500, nullable: false},
    Phone: {type: 'integer', nullable: true},
    IsSubscribed: {type: 'boolean', nullable: false},
    Role: {type: 'string', maxlength: 20, nullable: false}
  },
  cart: {
    CartId: {type: 'string', maxlength: 254, nullable: false, primary: true},
    UserId: {type: 'string', maxlength: 254, nullable: false}
  },
  cartitem: {
    CartId: {type: 'string', maxlength: 254, nullable: false},
    ItemId: {type: 'string', maxlength: 254, nullable: false},
    Quantity: {type: 'number', nullable: false}
  },
  donorrequests: {
    UserId: {type: 'string', maxlength: 254, nullable: false}
  },
  solditem: {
    ItemId: {type: 'string', maxlength: 254, nullable: false},
    SoldQuantity: {type: 'number', nullable: false},
    SoldDate: {type: 'date', nullable: false},
    Buyer: {type: 'string', maxlength: 254, nullable: false}
  }
};
module.exports = Schema;