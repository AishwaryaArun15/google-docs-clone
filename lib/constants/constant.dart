const String pathHost = 'http://localhost:3001/'; // 127.0.0.0 for android
const String pathAuthSignup = "api/signup";
const String pathCreateDocument = "api/createDocument";
const String pathGetMyDocument = "api/me";
const String pathUpdateDocumentTitle = "api/updateDocumentTitle";
String pathDocumentById(String id) => "api/document/$id";
