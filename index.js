const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
   res.send('Hello from multi-stage builds!');
});

app.listen(port, () => {
   console.log(`Server listening on port ${port}`);
});
