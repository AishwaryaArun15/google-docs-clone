const express = require('express');
const Document = require('../models/document_model');
const auth = require('../middleware/auth_middleware');

const documentRouter = express.Router();

documentRouter.post('/api/createDocument', auth, async (req, res) => {
        try {
            const { createdAt } = req.body;
            let document = new Document({
                uid: req.user,
                title: 'Untitled Document',
                createdAt,
            })

            document = await document.save();
            res.json(document);
        } catch (error) {
            console.log(error);
            res.status(500).json({error: e.message});
        }
});

documentRouter.post('/api/updateDocumentTitle', auth, async (req, res) => {
    try {
        const { id, title } = req.body;
       const document = await Document.findByIdAndUpdate(id, {title});
        res.json(document);
    } catch (error) {
        console.log(error);
        res.status(500).json({error: e.message});
    }
});

documentRouter.get('/api/me', auth, async(req, res) => {
    try {
        let documents = await Document.find({uid: req.user});
        res.json(documents);
    } catch (error) {
        console.log(error);
        res.status(500).json({error: e.message});
    }
});

documentRouter.get('/api/document/:id', auth, async(req, res) => {
    try {
        const document = await Document.findById(req.params.id);
        res.status(200).json(document);
    } catch (error) {
        console.log(error);
        res.status(500).json({error: e.message});
    }
});

module.exports = documentRouter;