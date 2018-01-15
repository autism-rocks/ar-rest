import Resource from '../model/resource';
import {DB} from '../database';
import express from 'express';
import isLoggedIn from '../context/isLoggedIn'

let router = express.Router();

router.get('/resources/:org_name', function (req, res, next) {
    req.user.organizations().query({where: {name: req.params.org_name}}).fetchOne().then((org) => {
        org.resources().query(q => {
            q.orderBy('created', 'DESC')
        }).fetch().then(resources => {
            res.send(resources);
        })
    }).catch(next);
});

/**
 * Creates a new resource
 */
router.post('/resources/:org_name', function (req, res, next) {
    req.user.organizations().query({where: {name: req.params.org_name}}).fetchOne().then((org) => {
        org.resources().create({
            title: req.body.title ? req.body.title : '',
            description: req.body.description ? req.body.description : '',
            created: new Date()
        }).then((n) => {
            res.send(n);
        });
    }).catch(next);
});

/**
 * Creates a new resource
 */
router.post('/resources/:org_name/:id_resource', function (req, res, next) {
    req.user.organizations().query({where: {name: req.params.org_name}}).fetchOne().then((org) => {
        org.resources().query({where: {id: req.params.id_resource}}).fetchOne().then((resource) => {
            ['title', 'description', 'url', 'tags'].forEach(f => {
                resource.set(f, req.body[f]);
            });

            resource.save().then(() => {
                res.send(resource);
            })
        });
    }).catch(next);
});

/**
 * Deletes a specific resource
 */
router.delete('/resources/:org_name/:id_resource', function (req, res, next) {
    req.user.organizations().query({where: {name: req.params.org_name}}).fetchOne().then((org) => {
        org.resources().query({where: {id: req.params.id_resource}}).fetchOne().then((resource) => {
            resource.destroy().then(() => {
                res.send(resource);
            })
        });
    }).catch(next);
});


export default function () {
    return router;
};
