// Import Web3 and handle wallet connection and authentication
async function authenticateUser() {
    if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        try {
            const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
            const account = accounts[0];
            
            const message = "Sign this message to authenticate for the quiz app.";
            const signature = await web3.eth.personal.sign(message, account);
            
            // Send account and signature to the backend for further verification (optional)
            return { account, signature };
        } catch (error) {
            console.error("Authentication failed", error);
        }
    } else {
        console.error("MetaMask not installed");
    }
}
