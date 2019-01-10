var FX2_Library_Bytes = artifacts.require('./base/library/FX2_Library_Bytes.sol')
var Migrations = artifacts.require('../contracts/Migrations.sol')


module.exports = function (deployer)
{
    deployer.deploy(FX2_Library_Bytes);
}
