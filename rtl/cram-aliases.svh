// CRAM field/subfield aliases
bit ADA_EN;
assign ADA_EN = CRAM.ADA[0];

bit AD_BOOL;
assign AD_BOOL = CRAM.AD[1];

bit [0:5] SPEC;
assign SPEC = CRAM.DISP;

bit [0:8] DIAG_FUNC;
assign DIAG_FUNC = CRAM.MAGIC;

bit [0:5] SKIP;
assign SKIP = CRAM.COND;
