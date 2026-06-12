import click
from structgen import builder

@click.group(invoke_without_command=True)
@click.pass_context
def cli(ctx):
    if ctx.invoked_subcommand is None:
        click.echo(ctx.get_help())
        ctx.exit()

@cli.command()
@click.option('--file', '-f', help="The file to build", multiple=True, required=True)
@click.option("--out", '-o', help="The output directory", default="out")
@click.option("--verbose", '-v', is_flag=True, help="Enable verbose mode")
def build(file, out, verbose):
    for i in file:
        click.echo(f"Building {i} to {out}...")
        build = builder.builder(i, out, verbose)
        build.build()

if __name__ == "__main__":
    cli()