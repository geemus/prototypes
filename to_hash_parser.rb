# TODO: possible weirdness comes from it basing array-ness on repeated occurence.
# So for instance if you remove one of the items in the belowe instanceSet it will stop being an array
# Or if you add an item to the groupSet it will start being an array
# I am currently uncertain of how much of a problem this might or might not be

require 'rubygems'
require 'nokogiri'
require 'pp'

data = <<-DATA
<DescribeInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2009-11-30/">
  <reservationSet>
    <item>
      <reservationId>r-44a5402d</reservationId>
      <ownerId>UYY3TLBUXIEON5NQVUUX6OMPWBZIQNFM</ownerId>
      <groupSet>
        <item>
          <groupId>default</groupId>
        </item>
      </groupSet>
      <instancesSet>
        <item>
          <instanceId>i-28a64341</instanceId>
          <imageId>ami-6ea54007</imageId>
          <instanceState>
            <code>0</code>
            <name>running</name>
          </instanceState>
          <privateDnsName>10-251-50-132.ec2.internal</privateDnsName>
          <dnsName>ec2-72-44-33-4.compute-1.amazonaws.com</dnsName>
          <keyName>example-key-name</keyName>
          <amiLaunchIndex>23</amiLaunchIndex>
          <productCodesSet>
            <item><productCode>774F4FF8</productCode></item>
          </productCodesSet>
          <instanceType>m1.large</instanceType>
          <launchTime>2007-08-07T11:54:42.000Z</launchTime>
          <placement>
			  <availabilityZone>us-east-1b</availabilityZone>
			  
	  </placement>
	  <kernelId>aki-ba3adfd3</kernelId>
	  <ramdiskId>ari-badbad00</ramdiskId>
        </item>
        <item>
          <instanceId>i-28a64435</instanceId>
          <imageId>ami-6ea54007</imageId>
          <instanceState>
            <code>0</code>
            <name>running</name>
          </instanceState>
          <privateDnsName>10-251-50-134.ec2.internal</privateDnsName>
          <dnsName>ec2-72-44-33-6.compute-1.amazonaws.com</dnsName>
          <keyName>example-key-name</keyName>
          <amiLaunchIndex>23</amiLaunchIndex>
          <productCodesSet>
            <item><productCode>774F4FF8</productCode></item>
          </productCodesSet>
          <instanceType>m1.large</instanceType>
          <launchTime>2007-08-07T11:54:42.000Z</launchTime>
          <placement>
			  <availabilityZone>us-east-1b</availabilityZone>
	  </placement>
	  <kernelId>aki-ba3adfd3</kernelId>
	  <ramdiskId>ari-badbad00</ramdiskId>
        </item>
      </instancesSet>
    </item>
  </reservationSet>
  
</DescribeInstancesResponse>
DATA

edge = <<-EDGE
<SupportedVersions xmlns="http://www.vmware.com/vcloud/versions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <VersionInfo>
    <Version>v0.8a-ext2.0</Version>
    <LoginUrl>https://services.enterprisecloud.terremark.com/api/v0.8a-ext2.0/login</LoginUrl>
  </VersionInfo>
  <VersionInfo>
    <Version>v0.8b-ext2.3</Version>
    <LoginUrl>https://services.enterprisecloud.terremark.com/api/v0.8b-ext2.3/login</LoginUrl>
  </VersionInfo>
  <VersionInfo>
    <Version>v0.8</Version>
    <LoginUrl>https://services.enterprisecloud.terremark.com/api/v0.8b-ext2.3/login</LoginUrl>
  </VersionInfo>
</SupportedVersions>
EDGE

class ToHashDocument < Nokogiri::XML::SAX::Document

  def initialize
    @stack = []
  end

  def characters(string)
    @value ||= ''
    @value << string.strip
  end

  def end_element(name)
    @stack.pop
    unless @value.empty?
      @stack.last[name.to_sym] = @value
      @value = ''
    end
  end

  def response
    @stack.first
  end

  def start_element(name, attributes = [])
    @value = ''
    parsed_attributes = {}
    for attribute in attributes
      key, value = attribute
      parsed_attributes[key.to_sym] = value
    end
    if @stack.last.is_a?(Array)
      @stack.last << {name.to_sym => parsed_attributes}
    else
      data = if @stack.empty?
        @stack.push(parsed_attributes)
        parsed_attributes
      elsif @stack.last[name.to_sym]
        unless @stack.last[name.to_sym].is_a?(Array)
          @stack.last[name.to_sym] = [@stack.last[name.to_sym]]
        end
        @stack.last[name.to_sym] << parsed_attributes
        @stack.last[name.to_sym].last
      else
        @stack.last[name.to_sym] = {}
        @stack.last[name.to_sym].merge(parsed_attributes)
        @stack.last[name.to_sym]
      end
      @stack.push(data)
    end
  end

end

document = ToHashDocument.new
parser = Nokogiri::XML::SAX::PushParser.new(document)
# parser << data
parser << edge
parser.finish
pp document.response