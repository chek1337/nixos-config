{ ... }:
{
  vim.git.gitsigns.mappings = {
    nextHunk = "]h";
    previousHunk = "[h";
    stageHunk = "<leader>ghs";
    undoStageHunk = "<leader>ghu";
    resetHunk = "<leader>ghr";
    stageBuffer = "<leader>ghS";
    resetBuffer = "<leader>ghR";
    previewHunk = "<leader>ghP";
    blameLine = "<leader>ghb";
    diffThis = null;
    diffProject = null;
    toggleBlame = "<leader>ghB";
    toggleDeleted = "<leader>ghx";
  };
}
