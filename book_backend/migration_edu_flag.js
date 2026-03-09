require('dotenv').config();
const mongoose = require('mongoose');
const Category = require('./models/Category');

mongoose.connect(process.env.MONGODB_URI).then(async () => {

    // Set 'textbooks' to have true
    await Category.updateMany({ slug: 'textbooks' }, { $set: { hasEducationConfig: true } });

    // Set everything else to have false (just to be safe, though default is false)
    await Category.updateMany({ slug: { $ne: 'textbooks' } }, { $set: { hasEducationConfig: false } });

    console.log('Successfully updated hasEducationConfig for all categories.');
    process.exit(0);

}).catch(err => {
    console.error(err);
    process.exit(1);
});
