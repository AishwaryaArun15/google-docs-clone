const express = require('express')
const mongoose = require('mongoose');
const authRouter = require('./routes/auth_routes');
const cors = require('cors');
var bodyParser = require('body-parser');
const documentRouter = require('./routes/document_routes');
const http = require('http');
const Document = require('./models/document_model');

const app = express()
const PORT = process.env.PORT | 3001

const DB = "mongodb+srv://aishwarya:aish15122000@cluster0.kcuf7.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
var server = http.createServer(app);
var io = require('socket.io')(server);


app.use(cors());
// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))
// parse application/json
app.use(bodyParser.json())

app.use(authRouter);
app.use(documentRouter);

mongoose.connect(DB)
.then(() => console.log("Connection Successful"))
.catch((err) => console.error(err)) 

io.on("connection", (socket) => {
    socket.on("join", (documentId) => {
        socket.join(documentId);
        
    });
    socket.on("typing", (data) => {
        socket.broadcast.to(data.room).emit("changes", data);
        
    });
    socket.on("save", (data) => {
        saveData(data);  
    });
});

const saveData = async(data) =>{
    let document = await Document.findById(data.room);
    document.content  = data.delta;
    document = await document.save();
}

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Listening at port ${PORT}`)
})