package vote

type Vote struct {
	Voteid        string `json:"voteid"`
	Voterid       string `json:"voterid"`
	IssueDateTime string `json:"issue_date_time"`
	Candidateid   string `json:"candidateid"`
}
