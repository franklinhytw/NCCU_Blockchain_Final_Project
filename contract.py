from solcx import compile_files

def getContractIface():
    # compile all contract files
    contracts = compile_files(["contract\product.sol"])

    # Compiled solidity code
    contract_interface = contracts['contract/product.sol:ProductTraceability']

    return contract_interface