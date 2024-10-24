const express = require('express');
const User = require('../models/user_model');
const jwt = require('jsonwebtoken');
const auth = require('../middleware/auth_middleware');
const authRouter = express.Router()

authRouter.post('/api/signup', async (req, res) => {
    try {
        const {name, email, profilePicture} = req.body;
        let user = await User.findOne({email: email});
        if(!user) {
            user = new User({
                email: email,
                name: name,
                profilePicture: profilePicture
            });
            user = await user.save();
        }

        const token = jwt.sign({id: user._id}, "passwordKey");
        res.status(200).json({user, token}); //shorthand for {user: user} -> same name
    } catch (error) {
        console.error(error);
        res.status(500).json({"error": error});
    }
});

authRouter.get("/", auth, async (req, res) => {
    let user = await User.findById(req.user);
    res.json({user, token: req.token});
})


module.exports = authRouter;