// Filename:    api/config/setup-env.js
// Used-by:     api/index.js
import dotenv from 'dotenv';
if (process.env.NODE_ENV !== 'production') { 
    dotenv.config({path: '.env.api'});
}