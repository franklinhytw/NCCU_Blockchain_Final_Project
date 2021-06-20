from contract import getContractIface
from schema import *

from web3 import Web3
from flask import Flask, request, render_template, jsonify
from web3.contract import ConciseContract

# web3.py instance
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

acoount_list = w3.eth.accounts

default_account = acoount_list[0]

transaction_details = {
    'from': default_account,
}

# get contract
contract_iface = getContractIface()
contract_bytecode = contract_iface['bin']
contract_abi = contract_iface['abi']

contract_factory = w3.eth.contract(
    abi=contract_abi,
    bytecode=contract_bytecode,
)

# here we pass in a list of smart contract constructor arguments. our contract constructor
# takes only one argument, a list of candidate names. the contract constructor contains
# information that we might want to change. below we pass in our list of voting candidates.
# the factory -> constructor design pattern gives us some flexibility when deploying contracts.
# if we wanted to deploy two contracts, each with different candidates, we could call the
# constructor() function twice, each time with different candidates.
#contract_constructor = contract_factory.constructor(default_account, default_account)

# here we deploy the smart contract. the bare minimum info we give about the deployment is which
# ethereum account is paying the gas to put the contract on the chain. the transact() function
# returns a transaction hash. this is like the id of the transaction on the chain
transaction_hash = contract_factory.constructor().transact(transaction_details)

# if we want our frontend to use our deployed contract as it's backend, the frontend
# needs to know the address where the contract is located. we use the id of the transaction
# to get the full transaction details, then we get the contract address from there
transaction_receipt = w3.eth.getTransactionReceipt(transaction_hash)
contract_address = transaction_receipt['contractAddress']

contract_instance = w3.eth.contract(
    abi=contract_abi,
    address=contract_address,
    # when a contract instance is converted to python, we call the native solidity
    # functions like: contract_instance.call().someFunctionHere()
    # the .call() notation becomes repetitive so we can pass in ConciseContract as our
    # parent class, allowing us to make calls like: contract_instance.someFunctionHere()
    ContractFactoryClass=ConciseContract,
)

print("Address:" + contract_address)

# initialize our flask app
app = Flask(__name__, static_url_path='', static_folder='assets')

# section_GET
@app.route('/', methods=['GET'])
def index():
    return render_template("index.html")

@app.route('/login', methods=['GET'])
def login():
    return render_template("login.html")
@app.route('/product/list', methods=['GET'])
def product_list():
    return render_template("product/list.html")
@app.route('/product/create', methods=['GET'])
def create_product():
    return render_template("product/create.html")
@app.route('/product/<productId>')
def detail_product():
    return render_template("product/detail.html")
# end_section_GET

# section_POST
@app.route('/add_product', methods=['POST'])
def add_product():
    body = request.json
    add_schema = AddProductSchema()
    try:
        result =  add_schema.load(body)
    except ValidationError as error:
        return error, 433       

    contract_instance.creationProduct(result["productId"], result["name"], result["description"], 
                            result["producer"], result["location"], transact=transaction_details)
    return render_template("index.html")

@app.route('/add_product_component', methods=['POST'])
def add_product_component():
    body = request.json
    add_schema = AddProductComponentSchema()
    try:
        result =  add_schema.load(body)
    except ValidationError as error:
        return error, 433   

    contract_instance.creationProductComponent(result["productId"], result["componentId"], result["name"], result["description"], 
                            result["producer"], result["location"], result["componentType"], transact=transaction_details)
    return "test"
# end_section_POST
if __name__ == '__main__':
    # set debug=True for easy development and experimentation
    # set use_reloader=False. when this is set to True it initializes the flask app twice. usually
    # this isn't a problem, but since we deploy our contract during initialization it ends up getting
    # deployed twice. when use_reloader is set to False it deploys only once but reloading is disabled
    app.run(debug=True, use_reloader=False)