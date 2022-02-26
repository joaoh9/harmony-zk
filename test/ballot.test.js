require('chai').use(require('chai-as-promised')).should();
const { expect } = require('chai');
const Ballot = artifacts.require('Ballot');
const E1155 = artifacts.require('E1155');
const E721 = artifacts.require('E721');

contract('Ballot tests', accounts => {
  beforeEach(async () => {
    i = await Ballot.new(
      [1, 2, 3],
      '0x0000000000000000000000000000000000000000',
      1,
      '0x0000000000000000000000000000000000000000'
    );
  });

  function BNtoStr(bn) {
    return bn.toString();
  }

  it.only('update erc721 token whitelist', async () => {
    await i.updateERC721ToWhitelist('0x0000000000000000000000000000000000000001', {
      from: accounts[1],
    }).should.be.rejected;

    await i.updateERC721ToWhitelist('0x0000000000000000000000000000000000000001');

    const newERC721 = await i.erc721whitelist();

    expect(newERC721).to.equal('0x0000000000000000000000000000000000000001');
  });

  it.only('update erc1155 token whitelist', async () => {
    await i.updateERC1155ToWhitelist('0x0000000000000000000000000000000000000000', 1, {
      from: accounts[1],
    }).should.be.rejected;

    await i.updateERC1155ToWhitelist('0x0000000000000000000000000000000000000000', 1);

    const newERC1155 = await i.erc1155whitelist();

    expect(newERC1155.addr_).to.equal('0x0000000000000000000000000000000000000000');
    expect(newERC1155.tokenId.toString()).to.equal('1');
  });

  it.only('vote with ERC1155 whitelist', async () => {
    const e1155 = await E1155.new('0x0', { from: accounts[1] });
    const balanceOf = await e1155.balanceOf(accounts[1], 1);
    expect(balanceOf.toString()).to.equal('10000');

    await i.updateERC1155ToWhitelist(e1155.address, 1);

    const newERC1155 = await i.erc1155whitelist();

    expect(newERC1155.addr_).to.equal(e1155.address);
    expect(newERC1155.tokenId.toString()).to.equal('1');

    await i.vote(1, { from: accounts[1] });
  });

  it.only('update erc1155 token whitelist', async () => {
    const e721 = await E721.new({ from: accounts[2] });
    const balanceOf = await e721.balanceOf(accounts[2]);
    expect(balanceOf.toString()).to.equal('1');

    await i.updateERC721ToWhitelist(e721.address);

    const newERC721 = await i.erc721whitelist();
    expect(newERC721).to.equal(e721.address);

    await i.vote(2, { from: accounts[2] });
  });
});
