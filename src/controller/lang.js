import express from 'express';
import Countries from 'countries-cities';
import Lang from '../model/lang';

let router = express.Router();


router.get('/langs', function(req, res) {

    Lang.fetchAll().then((langs) => {
        res.send(langs.map((l) => { return {
            id: l.get('id'),
            value: l.get('lang')
        }}));
    });
});

export default function() {

    return router;

};
