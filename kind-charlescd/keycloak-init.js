module.exports = async function (keycloak) {
    const realm = 'charlescd';
    const publicClient = {clientId: 'charlescd-client'}

    // create realm if not exists
    if (!await keycloak.realms.findOne({realm})) {
        await keycloak.realms.create({id: realm, realm});
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
            redirectUris: [ "http://charles.lvh.me/*" ],
            serviceAccountsEnabled: true,
            webOrigins: [ "*" ]
        });
        console.log(`client '${publicClient.clientId}' created`)
    }
    console.log(JSON.stringify(clients[0]))
}
