/**
 * This is the main entrypoint to your Probot app
 * @param {import('probot').Probot} app
 */
 module.exports = (app) => {

  app.on("pull_request.closed", async (context) => {


    const owner = context.payload.repository.owner.login;
    const title = context.payload.pull_request.title;
    const repo = context.payload.repository.name;
    const pull_number= context.payload.number;



    if (title == "update resource quotas"){
      const reviewers= await context.octokit.pulls.listReviews({
        owner,
        repo,
        pull_number,
      });
      const file= await context.octokit.repos.getContent({
        owner,
        repo,
        path : ".github/CODEOWNERS",
      });
      const content = Buffer.from(file.data.content, 'base64').toString('ascii');
      let index = content.search("@");
      const con =content.slice(index+1);
      context.log.info(reviewers);
      context.log.info(con);
      const input = await context.octokit.pulls.listFiles({
        owner,
        repo,
        pull_number,
      });
      // context.log.info(input);
      const filename = input.data[0].filename;
      context.log.info(filename);
      const inputfile= await context.octokit.repos.getContent({
        owner,
        repo,
        path : filename,
      });
      const input_content = Buffer.from(inputfile.data.content, 'base64').toString('ascii');
      context.log.info(input_content);


      await context.octokit.repos.createDispatchEvent({
        repo : 'central_repo',
        owner,
        event_type : 'trigger_workflow',
        client_payload : JSON.parse(input_content)
      });







    }
    else{
      context.log.info('hehe');
    }
  });

 }
