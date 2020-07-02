require 'coding_challenge/commands/start'

RSpec.describe CodingChallenge::Commands::Start do
  it "executes `start` command successfully" do
    output = StringIO.new
    options = {}
    command = CodingChallenge::Commands::Start.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
