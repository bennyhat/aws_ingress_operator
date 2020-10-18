defmodule AwsIngressOperator.Schemas.WritableSchema do
  defmacro __using__() do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      def changeset(changes), do: changeset(%__MODULE__{}, changes)

      def changeset(original, %_struct{} = changes),
        do: write_changeset(original, Map.from_struct(changes))

      def write_changeset(original, changes) do
        changest(original, changes)
      end

      defoverridable [write_changeset: 2]

      @before_compile {AwsIngressOperator.Schemas.WritableSchema, :before_compile}
    end
  end

  defmacro before_compile(_env) do
    quote do
      use Accessible
    end
  end
end
