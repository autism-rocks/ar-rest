/**
 * Responds with a 401 if the user is not authenticated
 *
 *
 * @param req
 * @param res
 * @param next
 * @returns {*}
 */
export default function (req, res, next) {
    if (req.isAuthenticated())
        return next();
    else {
        res.status(401).send()
    }
}