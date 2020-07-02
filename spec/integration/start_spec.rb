RSpec.describe "`coding_challenge start` command", type: :cli do
  it "executes `coding_challenge help start` command successfully" do
    output = `coding_challenge help start`
    expected_output = <<-OUT
Usage:
  coding_challenge start

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
