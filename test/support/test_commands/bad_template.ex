defmodule Cog.Support.TestCommands.BadTemplate do
  use Cog.Command.GenCommand.Base, bundle: Cog.Util.Misc.embedded_bundle, name: "bad-template"

  @description "description"

  rule "when command is #{Cog.Util.Misc.embedded_bundle}:bad-template allow"

  def handle_message(req, state) do
    {:reply, req.reply_to, "badtemplate", %{bad: %{foo: "bar"}}, state}
  end
end
