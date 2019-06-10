const figlet = require('figlet');

let out = figlet.textSync('Hello World!', {
    font: 'Standard'
});

console.log(out);