require "yaml"
require "./spec_helper"

describe BERT do
  describe "VERSION" do
    it "matches shards.yml" do
      version = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))["version"].as_s
      version.should eq(VERSION)
    end
  end
end
