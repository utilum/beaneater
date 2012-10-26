# test/connection_test.rb

require File.expand_path('../test_helper', __FILE__)

describe Beaneater::Connection do

  describe 'for #new' do
    before do
      @host_string_port = 'localhost:11301'
      @host_num_port = '127.0.0.1:11302'
      @host_string = 'host.local'
      @host_num = '1.1.1.1:11303'
      @hosts = [@host_string_port, @host_num_port, @host_string, @host_num]

      Net::Telnet.expects(:new).with('Host' => 'localhost', "Port" => 11301, "Prompt" => /\n/).once
      Net::Telnet.expects(:new).with('Host' => '127.0.0.1', "Port" => 11302, "Prompt" => /\n/).once
      Net::Telnet.expects(:new).with('Host' => 'host.local', "Port" => 11300, "Prompt" => /\n/).once
      Net::Telnet.expects(:new).with('Host' => '1.1.1.1', "Port" => 11303, "Prompt" => /\n/).once

      @bc = Beaneater::Connection.new(@hosts)
    end

    it "should init 4 telnet connections" do
      assert_equal 4, @bc.telnet_connections.size
    end
  end #new

  describe 'for #transmit_to_all' do
    before do
      @hosts = ['localhost', 'localhost']
      @bc = Beaneater::Connection.new(@hosts)
    end

    it "should return yaml loaded response" do
      res = @bc.transmit_to_all 'stats'
      assert_equal 2, res.size
      refute_nil res.first[:body]['current-connections']
    end
  end #transmit_to_all

  describe 'for #transmit_to_rand' do
    before do
      @hosts = ['localhost', 'localhost']
      @bc = Beaneater::Connection.new(@hosts)
    end

    it "should return yaml loaded response" do
      res = @bc.transmit_to_rand 'stats'
      refute_nil res[:body]['current-connections']
      assert_equal 'OK', res[:status]
    end

    it "should return id" do
      Net::Telnet.any_instance.expects(:cmd).with('String' => 'foo').returns('INSERTED 254')
      res = @bc.transmit_to_rand 'foo'
      assert_equal '254', res[:id]
      assert_equal 'INSERTED', res[:status]
    end
  end #transmit_to_rand

  describe 'for #stats' do
    before do
      @hosts = ['localhost', 'localhost']
      @bc = Beaneater::Connection.new(@hosts)
    end

    it("should return stats object"){ assert_kind_of Beaneater::Stats, @bc.stats }
  end #stats

  describe 'for #tubes' do
    before do
      @hosts = ['localhost', 'localhost']
      @bc = Beaneater::Connection.new(@hosts)
    end

    it("should return Tubes object"){ assert_kind_of Beaneater::Tubes, @bc.tubes }
  end #tubes

end # Beaneater::Connection