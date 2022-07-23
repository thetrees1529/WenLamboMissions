const config = require("./missionConfig.js")
const fs = require("fs").promises
const path = require("path")
async function main() {
    await fs.writeFile(path.join(__dirname, "outputs/pastableString.txt"), JSON.stringify(config))
}
main()