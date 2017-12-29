import express from 'express';
import Countries from 'countries-cities';

let router = express.Router();


router.get('/geo/countries', function(req, res) {
    let countries = Countries.getCountries().sort().map((c) => {
        return {id: c, value:c}
    });
    countries.unshift({id:null, value:''});
    res.send(countries);
});

router.get('/geo/cities', function(req, res) {
    res.send(Countries.getCities(req.query.country).sort().map((c) => {
        return {id: c, value:c}
    }));
});

export default function() {

    return router;

};
