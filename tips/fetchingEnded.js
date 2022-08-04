


const entries = []

const inProgress = entries.filter(entry => !entry.ended)
const inProgressAndEndable = inProgress.filter(inProgress => Date.now() >= inProgress.endsAt)
