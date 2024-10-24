const jwt = require('jsonwebtoken');

const auth = async(req, res, next) => {
    try {
        const token = req.header("x-auth-token");
        if(!token) {
           return res.status(401).json({error: "No auth token. Access Denied"});
        }

        const verified = jwt.verify(token, "passwordKey");
        if(!verified) {
            return res.status(401).json({error: "Token verification Failed. Try again later"});
         }

         req.user = verified.id;
         req.token = token;
         next();

    } catch(e) {
        res.status(500).json({error: "Server Error"});
    }
}

module.exports = auth;