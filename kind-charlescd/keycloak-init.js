module.exports = async function (keycloak) {
    const realm = 'charlescd';
    const publicClient = {clientId: 'charlescd-client'}
    const confidentialClient = {clientId: 'realm-charlescd'}

    // create realm if not exists
    if (!await keycloak.realms.findOne({realm})) {
        await keycloak.realms.create({id: realm, realm, enabled: true});
        console.log(`realm '${realm}' created`)
    }

    // change default realm
    keycloak.setConfig({realmName: realm});

    // create public client if not exists
    let clients = await keycloak.clients.find({clientId: publicClient.clientId});
    if (!clients || clients.length === 0) {
        await keycloak.clients.create({
            clientId: publicClient.clientId,
            directAccessGrantsEnabled: true,
            implicitFlowEnabled: true,
            publicClient: true,
            redirectUris: ["http://charles.lvh.me/*"],
            serviceAccountsEnabled: true,
            webOrigins: ["*"]
        });
        console.log(`client '${publicClient.clientId}' created`)
    }

    // create confidential client if not exists
    clients = await keycloak.clients.find({clientId: confidentialClient.clientId});
    if (!clients || clients.length === 0) {
        await keycloak.clients.create({
            clientId: confidentialClient.clientId,
            secret: process.env.CLIENT_SECRET,
            serviceAccountsEnabled: true,
            standardFlowEnabled: false,
        });
        console.log(`client '${confidentialClient.clientId}' created`)
    }

    // create admin user if not exists
    const username = "charlesadmin@admin"
    clients = await keycloak.users.find({username});
    if (!clients || clients.length === 0) {
        const {id} = (await keycloak.users.create({
            username,
            enabled: true,
            emailVerified: true,
            email: username,
            attributes: {isRoot: ["true"]},
        }))
        console.log(`user '${username}' created`)
        await keycloak.users.resetPassword({
            id,
            credential: {type: "password", value: process.env.USER_PASSWORD, temporary: false},
        });
        console.log(`credentials of '${username}' have been set`)
    }
}
