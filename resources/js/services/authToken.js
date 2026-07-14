let _token = null;
let _user = null;

export function getToken() {
    return _token;
}

export function setToken(token) {
    _token = token;
}

export function getUser() {
    return _user;
}

export function setUser(user) {
    _user = user;
}

export function clearAuth() {
    _token = null;
    _user = null;
}
