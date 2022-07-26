

async function main() {
    [1,1,1,1,1,1].forEach(async () => {
        console.log(1)
        await new Promise(resolve => setTimeout(resolve, 1000))
    })    
}
main()