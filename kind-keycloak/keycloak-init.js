module.exports = async function (keycloak) {
    const realm = 'Kurtis';

    await createRealms(keycloak, [{id: realm, realm, enabled: true}])

    keycloak.setConfig({realmName: realm});

    await createClients(keycloak, [
        {
            clientId: 'demo-frontend',
            attributes: {'pkce.code.challenge.method': 'S256'},
            directAccessGrantsEnabled: true,
            publicClient: true,
            redirectUris: ['http://127.0.0.1:8000/*', 'http://0.0.0.0:8000/*', 'http://localhost:8000/*'],
            webOrigins: ['http://0.0.0.0:8000', 'http://127.0.0.1:8000', 'http://localhost:8000']
        },
        {clientId: 'demo-backend', secret: process.env.CLIENT_SECRET, standardFlowEnabled: false}
    ])

    await createUsers(keycloak, [
        {
            username: "tiago",
            enabled: true,
            totp: false,
            emailVerified: true,
            firstName: "Tiago",
            lastName: "Angelo",
            email: "tiago@gmail.com",
            credentials: [{type: "password", value: "abc123", temporary: false}]
        },
        {
            username: "maria",
            enabled: true,
            totp: false,
            emailVerified: true,
            firstName: "Maria Cláudia",
            lastName: "Saccomani",
            email: "maria@gmail.com",
            credentials: [{type: "password", value: "abc123", temporary: false}]
        }
    ])
}

async function createRealms(keycloak, realms) {
    for (const realm of realms) if (!await keycloak.realms.findOne({realm: realm.realm})) {
        await keycloak.realms.create(realm);
        console.log(`realm '${realm.realm}' created`)
    }
}

async function createClients(keycloak, clients) {
    for (const client of clients) {
        const found = await keycloak.clients.find({clientId: client.clientId});
        if (!found || found.length === 0) {
            await keycloak.clients.create(client);
            console.log(`client '${client.clientId}' created`)
        }
    }
}

async function createUsers(keycloak, users) {
    for (const user of users) {
        const found = await keycloak.users.find({username: user.username});
        if (!found || found.length === 0) {
            await keycloak.users.create(user);
            console.log(`users '${user.username}' created`)
        }
    }
}
